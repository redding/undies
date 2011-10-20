require 'undies/source_stack'
require 'undies/element_stack'
require 'undies/node_list'

module Undies
  class RenderData

    attr_reader :io, :pp, :nodes, :source_stack, :element_stack

    def initialize(source, opts={})
      self.source = source
      self.options = opts
      @nodes = NodeList.new(@io)
    end

    def source=(source)
      @source_stack = SourceStack.new(source)
    end

    def options=(opts)
      if !opts.kind_of?(::Hash)
        raise ArgumentError, "please provide a hash to set options with"
      end

      @io = opts[:io] if opts.has_key?(:io)
      @pp = opts[:pp] if opts.has_key?(:pp)
      @element_stack = ElementStack.new(self, @io)
    end

    def append(node)
      self.element_stack.last.instance_variable_get("@nodes").append(node)
    end

    def node(data="")
      self.append(Node.new(data.to_s))
    end

    def element(name, attrs={}, &block)
      self.append(Element.new(self.element_stack, name, attrs, &block))
    end

    # TODO: may be obsolete if we do full streaming solution
    def output
      self.nodes.to_s(0, @pp)
    end

  end
end
