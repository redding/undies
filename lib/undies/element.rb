require 'undies/node'

module Undies
  class Element < Node

    # have as many methods to the class level as possilbe to keep from
    # polluting the public instance methods and to maximize the effectiveness
    # of the Element#method_missing logic

    def self.html_attrs(attrs="", ns=nil)
      if attrs.kind_of? ::Hash
        attrs.empty? ? '' : (attrs.keys.map(&:to_s).sort.map(&:to_sym).inject('') do |html, key|
          ak = ns ? "#{ns}_#{key}" : key.to_s
          av = attrs[key]
          html + (av.kind_of?(::Hash) ? html_attrs(av, ak) : " #{ak}=\"#{av}\"")
        end)
      else
        attrs.to_s
      end
    end

    def self.content_blocks(element)
      element.instance_variable_get("@content_blocks")
    end

    def self.content(element)
      self.content_blocks(element).each{ |content| content.call }
      nil
    end

    def self.start_tag(element)
      name = element.instance_variable_get("@name")
      html_attrs = self.html_attrs(element.instance_variable_get("@attrs"))
      cb_count = self.content_blocks(element).size
      "<#{name}#{html_attrs}" + (cb_count > 0 ? ">" : " />")
    end

    def self.end_tag(element)
      name = element.instance_variable_get("@name")
      cb_count = self.content_blocks(element).size
      cb_count > 0 ? "</#{name}>" : nil
    end

    def self.flush(element, node_stack)
      node_stack.output << self.start_tag(element)
      node_stack.output.pp_level(:up)
      node_stack.output << self.content(element)
      node_stack.pop
      node_stack.output.pp_level(:down)
      node_stack.output << self.end_tag(element)
    end

    def initialize(name, attrs={}, &block)
      if !attrs.kind_of?(::Hash)
        raise ArgumentError, "#{name.inspect} attrs must be provided as a Hash."
      end

      @name  = name.to_s
      @attrs = attrs
      @content_blocks = []
      @content_blocks << block if block

      @proxy_lambda = lambda do |value, attrs, content_block, &block|
        block.call(value)
        @attrs.merge!(attrs)
        @content_blocks << content_block if content_block
        self
      end
    end

    # CSS proxy methods ============================================
    ID_METH_REGEX = /^([^_].+)!$/
    CLASS_METH_REGEX = /^([^_].+)$/

    def method_missing(meth, *args, &block)
      if meth.to_s =~ ID_METH_REGEX
        @proxy_lambda.call($1, args.first || {}, block) do |value|
          @attrs.merge!(:id => value)
        end
      elsif meth.to_s =~ CLASS_METH_REGEX
        @proxy_lambda.call($1, args.first || {}, block) do |value|
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

  end
end
