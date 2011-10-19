require 'undies/source_stack'
require 'undies/element_stack'
require 'undies/node_list'

module Undies
  class Renderer

    attr_reader :io, :pp
    attr_accessor :source_stack

    def initialize(source, opts={})
      # @io = opts[:io]
      # @pp = opts[:pp]
      self.source = source
    end

    def source=(source)
      self.source_stack = SourceStack.new(source)
    end

    def element_stack
      @element_stack ||= ElementStack.new(self)
    end

    def nodes
      @nodes ||= NodeList.new
    end

  end
end
