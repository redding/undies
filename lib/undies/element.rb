require 'undies/node'
require 'undies/node_list'
require 'undies/element_stack'

module Undies
  class Element < Node

    # wrapping as many public methods as possible in triple underscore to not
    # pollute the public scope.  trying to make the method missing stuff as
    # effective as possible.

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

    def initialize(stack, name, attrs={}, &block)
      if !stack.kind_of?(ElementStack)
        raise ArgumentError, "stack must be an Undies::ElementStack"
      end
      if !attrs.kind_of?(::Hash)
        raise ArgumentError, "#{name.inspect} attrs must be provided as a Hash."
      end

      super(@nodes = NodeList.new)
      @element_stack = stack
      @yields = 0
      @name = name.to_s
      @attrs = attrs

      self.___yield___(block)
    end

    def ___yield___(content_block)
      if content_block
        @yields += 1
        @element_stack.push(self)
        content_block.call
        @element_stack.pop
      end
    end

    def ___name___;  @name;  end
    def ___attrs___; @attrs; end
    # def ___attrs___=(value); @attrs = value; end
    def ___nodes___; @nodes; end

    def ___start_tag___
      "<#{@name}#{self.class.html_attrs(@attrs)}" + (@yields > 0 ? ">" : " />")
    end

    def ___end_tag___
      @yields > 0 ? "</#{@name}>" : nil
    end

    # CSS proxy methods ============================================
    ID_METH_REGEX = /^([^_].+)!$/
    CLASS_METH_REGEX = /^([^_].+)$/

    def method_missing(meth, *args, &block)
      if meth.to_s =~ ID_METH_REGEX
        ___proxy_id_attr___($1, *args, &block)
      elsif meth.to_s =~ CLASS_METH_REGEX
        ___proxy_class_attr___($1, *args, &block)
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
      other.___name___  == self.___name___  &&
      other.___attrs___ == self.___attrs___ &&
      other.___nodes___ == self.___nodes___
    end

    # overriding this because the base Node class defines a 'to_s' method that
    # needs to be honored
    def to_str(*args)
      "Undies::Element:#{self.object_id} " +
      "@name=#{@name.inspect}, @attrs=#{@attrs.inspect}, @nodes=#{@nodes.inspect}"
    end
    alias_method :inspect, :to_str

    def to_ary(*args); @nodes; end

    private

    def ___proxy_id_attr___(value, attrs={}, &content_block)
      @attrs.merge!(:id => value)
      @attrs.merge!(attrs)
      self.___yield___(content_block)
      self
    end

    def ___proxy_class_attr___(value, attrs={}, &content_block)
      @attrs[:class] = [@attrs[:class], value].compact.join(' ')
      @attrs.merge!(attrs)
      self.___yield___(content_block)
      self
    end

  end
end
