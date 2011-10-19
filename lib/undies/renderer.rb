# require 'undies/source_stack'
require 'undies/element_stack'
require 'undies/node_list'

module Undies
  class Renderer

    attr_reader :io, :pp

    def initialize(source, opts={})
      # @io = opts[:io]
      # @pp = opts[:pp]

    end

    def source_stack
    end

    def element_stack
      @element_stack ||= ElementStack.new(self)
    end

    def nodes
      @nodes ||= NodeList.new
    end

  end
end
