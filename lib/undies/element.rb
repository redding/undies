require 'undies/node'
require 'undies/node_list'
require 'undies/element_stack'

module Undies
  class Element < Node

    attr_reader :___name, :___attrs
    attr_accessor :___nodes

    def initialize(stack, name, attrs={}, &block)
      if !stack.kind_of?(ElementStack)
        raise ArgumentError, "stack must be an Undies::ElementStack"
      end
      if !attrs.kind_of?(::Hash)
        raise ArgumentError, "#{name.inspect} attrs must be provided as a Hash."
      end
      super(@___nodes = NodeList.new)
      @stack = stack
      @content_writes = 0
      @___name = name.to_s
      @___attrs = attrs
      self.___content = block
    end

    def start_tag
      "<#{@___name}#{html_attrs(@___attrs)}" + (@content_writes > 0 ? ">" : " />")
    end

    def end_tag
      @content_writes > 0 ? "</#{@___name}>" : nil
    end

    # CSS proxy methods ============================================
    ID_METH_REGEX = /^([^_].+)!$/
    CLASS_METH_REGEX = /^([^_].+)$/

    def method_missing(meth, *args, &block)
      if meth.to_s =~ ID_METH_REGEX
        proxy_id_attr($1, *args, &block)
      elsif meth.to_s =~ CLASS_METH_REGEX
        proxy_class_attr($1, *args, &block)
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
      other.___name  == self.___name  &&
      other.___attrs == self.___attrs &&
      other.___nodes == self.___nodes
    end

    def to_str(*args)
      "Undies::Element:#{self.object_id} " +
      "@name=#{self.___name.inspect}, @attrs=#{self.___attrs.inspect}, @nodes=#{self.___nodes.inspect}"
    end
    alias_method :inspect, :to_str

    def to_ary(*args)
      self.___nodes
    end

    protected

    def html_attrs(attrs="", ns=nil)
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

    private

    def proxy_id_attr(value, attrs={}, &block)
      self.___attrs.merge!(:id => value)
      self.___attrs.merge!(attrs)
      self.___content = block
      self
    end

    def proxy_class_attr(value, attrs={}, &block)
      self.___attrs[:class] = [self.___attrs[:class], value].compact.join(' ')
      self.___attrs.merge!(attrs)
      self.___content = block
      self
    end

    def ___content=(block)
      if block
        @content_writes += 1
        @stack.push(self)
        block.call
        @stack.pop
      end
    end

  end
end
