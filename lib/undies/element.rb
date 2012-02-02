require 'undies/node'

module Undies
  class Element < Node

    # have as many methods to the class level as possilbe to keep from
    # polluting the public instance methods and to maximize the effectiveness
    # of the Element#method_missing logic

    def self.hash_attrs(attrs="", ns=nil)
      return attrs.to_s if !attrs.kind_of?(::Hash)

      {}.tap do |a|
        attrs.each { |k, v| a[ns ? "#{ns}_#{k}" : k.to_s] = v }
      end.sort.inject('') do |html, k_v|
        html + if k_v.last.kind_of?(::Hash)
          hash_attrs(k_v.last, k_v.first)
        else
          " #{k_v.first}=\"#{escape_attr_value(k_v.last)}\""
        end
      end
    end

    def self.escape_attr_value(value)
      value.
        to_s.
        gsub('&', '&amp;').
        gsub('<', '&lt;').
        gsub('"', '&quot;')
    end

    def self.set_children(element)
      element.instance_variable_set("@children", true)
    end

    def self.children(element)
      element.instance_variable_get("@children")
    end

    def self.prefix(element, meth, level, indent)
      "".tap do |value|
        if indent > 0
          if meth == 'start_tag'
            value << "#{level > 0 ? "\n": ''}#{' '*level*indent}"
          elsif meth == 'end_tag'
            value << "\n#{' '*level*indent}" if children(element)
          end
        end
      end
    end

    def initialize(name, attrs={}, &build)
      super(nil)
      @content = nil
      @builds = []
      @children = false

      if !attrs.kind_of?(::Hash)
        raise ArgumentError, "#{name.inspect} attrs must be provided as a Hash."
      end

      @name  = name.to_s
      @attrs = attrs
      @builds << build if build

      # cache in an instance variable for fast access with flush and pop
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
      other.instance_variable_get("@attrs") == @attrs
    end

    # overriding this because the base Node class defines a 'to_s' method that
    # needs to be honored
    def to_str(*args)
      "Undies::Element:#{self.object_id} " +
      "@name=#{@name.inspect}, @attrs=#{@attrs.inspect}"
    end
    alias_method :inspect, :to_str

    private

    def proxy(value, attrs, build)
      yield value if block_given?
      @attrs.merge!(attrs)
      @builds << build if build

      # cache in an instance variable for fast access with flush and pop
      @start_tag = start_tag
      @end_tag = end_tag

      # return self so you can chain proxy method calls
      self
    end

    def start_tag
      "<#{@name}#{self.class.hash_attrs(@attrs)}" + (@builds.size > 0 ? ">" : " />")
    end

    def end_tag
      @builds.size > 0 ? "</#{@name}>" : nil
    end

  end
end
