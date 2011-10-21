require 'undies/source_stack'
require 'undies/element_stack'
require 'undies/node_list'
require 'undies/output'

module Undies
  class RenderData

    attr_reader :io, :pp, :nodes, :source_stack, :element_stack

    def initialize(source, output)
      self.source = source
      self.output = output

      # TODO: may not be needed going forward
      @nodes = NodeList.new(@output)
    end

    def source=(value)
      @source_stack = SourceStack.new(value)
    end

    def output=(value)
      if !value.kind_of?(Output)
        raise ArgumentError, "please provide an Output object"
      end

      @output = value

      # TODO: pass the output obj to the element stack
      @element_stack = ElementStack.new(@output, self)

      # TODO: not needed going forward
      @io = @output.io
      @pp = @output.pp

      @output
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
