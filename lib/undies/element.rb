require 'undies/node'

module Undies
  class Element < Node

    # have as many methods to the class level as possilbe to keep from
    # polluting the public instance methods and to maximize the effectiveness
    # of the Element#method_missing logic

    def self.html_attrs(attrs="", ns=nil)
      return attrs.to_s if !attrs.kind_of?(::Hash)

      {}.tap do |a|
        attrs.each { |k, v| a[ns ? "#{ns}_#{k}" : k.to_s] = v }
      end.sort.inject('') do |html, k_v|
        html + if k_v.last.kind_of?(::Hash)
          html_attrs(k_v.last, k_v.first)
        else
          " #{k_v.first}=\"#{k_v.last}\""
        end
      end
    end

    def self.content(element)
      nil
    end

    def self.flush(output, element)
      output.pp_use_indent = true
      output << element.instance_variable_get("@start_tag")
      if (cbs = element.instance_variable_get("@content_blocks")).size > 0
        output.pp_level += 1
        output.pp_use_indent = false
        cbs.each{ |content| content.call }
        output.flush
        output.pp_level -= 1
      end
      output << element.instance_variable_get("@end_tag") if element.instance_variable_get("@end_tag")
      output.pp_use_indent = true
    end

    def initialize(name, attrs={}, &block)
      if !attrs.kind_of?(::Hash)
        raise ArgumentError, "#{name.inspect} attrs must be provided as a Hash."
      end

      @name  = name.to_s
      @attrs = attrs
      @content_blocks = []
      @content_blocks << block if block
      @start_tag = start_tag
      @end_tag = end_tag
    end

    # CSS proxy methods ============================================
    ID_METH_REGEX = /^([^_].+)!$/
    CLASS_METH_REGEX = /^([^_].+)$/

    def method_missing(meth, *args, &block)
      if meth.to_s =~ ID_METH_REGEX
        proxy($1, args.first || {}, block) do |value|
          @attrs.merge!(:id => value)
        end
      elsif meth.to_s =~ CLASS_METH_REGEX
        proxy($1, args.first || {}, block) do |value|
          @attrs[:class] = [@attrs[:class], value].compact.join(' ')
        end
      else
        super
      end
    end

    def respond_to?(*args)
      if args.first.to_s =~ ID_METH_REGEX || args.first.to_s =~ CLASS_METH_REGEX
        true
      else
        super
      end
    end
    # ==============================================================

    def ==(other)
      other.instance_variable_get("@name")  == @name  &&
      other.instance_variable_get("@attrs") == @attrs &&
      other.instance_variable_get("@nodes") == @nodes
    end

    # overriding this because the base Node class defines a 'to_s' method that
    # needs to be honored
    def to_str(*args)
      "Undies::Element:#{self.object_id} " +
      "@name=#{@name.inspect}, @attrs=#{@attrs.inspect}, @nodes=#{@nodes.inspect}"
    end
    alias_method :inspect, :to_str

    private

    def proxy(value, attrs, content_block)
      yield value if block_given?
      @attrs.merge!(attrs)
      @content_blocks << content_block if content_block
      @start_tag = start_tag
      @end_tag = end_tag
      self
    end

    def start_tag
      "<#{@name}#{self.class.html_attrs(@attrs)}" + (@content_blocks.size > 0 ? ">" : " />")
    end

    def end_tag
      @content_blocks.size > 0 ? "</#{@name}>" : nil
    end

  end
end
