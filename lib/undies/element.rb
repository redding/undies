require 'undies/node'
require 'undies/node_list'
require 'undies/element_stack'

module Undies
  class Element < Node

    # moving as many methods to the class level as possilbe to keep from
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

    def self.start_tag(element)
      name = element.instance_variable_get("@name")
      html_attrs = self.html_attrs(element.instance_variable_get("@attrs"))
      yield_count = element.instance_variable_get("@yield_count")
      "<#{name}#{html_attrs}" + (yield_count > 0 ? ">" : " />")
    end

    def self.end_tag(element)
      name = element.instance_variable_get("@name")
      yield_count = element.instance_variable_get("@yield_count")
      yield_count > 0 ? "</#{name}>" : nil
    end


    def initialize(element_stack, name, attrs={}, &block)
      if !element_stack.kind_of?(ElementStack)
        raise ArgumentError, "stack must be an Undies::ElementStack"
      end
      if !attrs.kind_of?(::Hash)
        raise ArgumentError, "#{name.inspect} attrs must be provided as a Hash."
      end

      @name  = name.to_s
      @attrs = attrs
      @nodes = NodeList.new

      @element_stack = element_stack
      @yield_count = 0

      super(@nodes)
      self.___yield___(block)
    end

    def ___yield___(content_block)
      if content_block
        @yield_count += 1
        @element_stack.push(self)
        content_block.call
        @element_stack.pop
      end
    end

    # CSS proxy methods ============================================
    ID_METH_REGEX = /^([^_].+)!$/
    CLASS_METH_REGEX = /^([^_].+)$/

    def method_missing(meth, *args, &block)
      if meth.to_s =~ ID_METH_REGEX
        value = $1
        attrs = args.first || {}
        content_block = block

        @attrs.merge!(:id => value)
        @attrs.merge!(attrs)
        self.___yield___(content_block)
        self
      elsif meth.to_s =~ CLASS_METH_REGEX
        value = $1
        attrs = args.first || {}
        content_block = block

        @attrs[:class] = [@attrs[:class], value].compact.join(' ')
        @attrs.merge!(attrs)
        self.___yield___(content_block)
        self
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

    def to_ary(*args); @nodes; end

  end
end
