require 'undies/source_stack'
require 'undies/element_stack'
require 'undies/node_list'

module Undies
  class Renderer

    attr_reader :io, :pp, :nodes, :source_stack, :element_stack

    def initialize(source, opts={})
      self.source = source
      self.options = opts
      @nodes = NodeList.new
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

    # convenience method so api matches up with element api
    def ___nodes___; self.nodes; end

    def to_s
      self.nodes.to_s(0, @pp)
    end


  end
end