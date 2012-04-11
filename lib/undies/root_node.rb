module Undies

  class RootAPIError < RuntimeError; end

  class RootNode

    # Used internally to implement the markup tree nodes.  Each node caches and
    # processes nested markup and elements.  At each node level in the markup
    # tree, nodes/markup are cached until the next sibling node or raw markup
    # is defined, or until the node is flushed.  This keeps nodes from bloating
    # memory on large documents and allows for output streaming.

    # RootNode is specifically used to handle root document markup.

    attr_reader :io, :cached

    def initialize(io)
      @io = io
      @cached = nil
    end

    def attrs(*args, &block)
      raise RootAPIError, "can't call '__attrs' at the root node level"
    end

    def text(raw)
      write_cached
      @cached = "#{@io.line_indent}#{raw.to_s}#{@io.newline}"
    end

    def element_node(element_node)
      write_cached
      @cached = element_node
    end

    def partial(partial)
      text(partial)
    end

    def flush
      write_cached
      @cached = nil
      self
    end

    def push
      @io.push(@cached)
      @cached = nil
    end

    def pop
      flush
    end

    private

    def write_cached
      @io << @cached.to_s
    end

  end
end
