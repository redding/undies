require 'undies/source_stack'
require 'undies/node_stack'
require 'undies/node'
require 'undies/element'
require 'undies/output'

module Undies
  class RenderData

    attr_reader :source_stack, :node_stack, :output

    def initialize(source, output)
      self.source = source
      self.output = output
    end

    def source=(value)
      @source_stack = SourceStack.new(value)
    end

    def output=(value)
      if !value.kind_of?(Output)
        raise ArgumentError, "please provide an Output object"
      end

      @node_stack = NodeStack.new(value)
      @output = value
    end

    def node(data="")
      self.flush
      self.node_stack.push(Node.new(data))
    end

    def element(name, attrs={}, &block)
      self.flush
      self.node_stack.push(Element.new(name, attrs, &block))
    end

    def flush
      self.node_stack.pop
    end

  end
end
