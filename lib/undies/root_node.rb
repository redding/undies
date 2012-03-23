module Undies

  class RootNode

    # Used internally to implement the markup tree nodes.  Each node caches and
    # processes nested markup and elements.  At each node level in the markup
    # tree, nodes/markup are cached until the next sibling node or raw markup
    # is defined, or until the node is flushed.  This keeps nodes from bloating
    # memory on large documents and allows for output streaming.

    # Node is specifically used to handle root document markup.

    def initialize(io)
      @io = io
      @cached = nil
      @builds = []
    end

    def __cached; @cached; end
    def __builds; @builds; end

    # just silently do nothing - shouldn't be called on a plain Node
    def __attrs(*args, &block); end

    def __flush
      write_cached
      @cached = nil
    end

    def __push
      @io.push(@cached)
      @cached = nil
    end

    def __pop
      __flush
    end

    def __markup(raw)
      write_cached
      @cached = "#{@io.line_indent}#{raw.to_s}#{@io.newline}"
    end

    def __partial(partial)
      __markup(partial)
    end

    def __element(element)
      write_cached
      @cached = element
    end

    private

    def write_cached
      @io << @cached.to_s if @cached
    end

  end
end
