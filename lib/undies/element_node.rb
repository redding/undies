module Undies

  class ElementAPIError < RuntimeError; end

  class ElementNode

    # Used internally to implement the markup tree nodes.  Each node caches and
    # processes nested markup and elements.  At each node level in the markup
    # tree, nodes/markup are cached until the next sibling node or raw markup
    # is defined, or until the node is flushed.  This keeps nodes from bloating
    # memory on large documents and allows for output streaming.

    # ElementNode is specifically used to handle nested element markup.

    attr_reader :io, :element, :cached

    def initialize(io, element)
      @io = io
      @cached = nil
      @element = element

      @start_tag_written = false
    end

    def attrs(*args)
      @element.__attrs(*args)
    end

    def text(raw)
      raise ElementAPIError, "can't insert text markup in an element build block - pass in as a content argument instead"
    end

    def element_node(element_node)
      if !@start_tag_written
        # with newline
        # -1 level offset b/c we are operating on the element build one deep
        write_start_tag(@io.newline, -1)
      end
      write_cached
      @cached = element_node
    end

    def partial(partial)
      element_node(partial)
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
      @io.pop
      write_end_tag
    end

    def to_s
      @io.push(self)

      @element.__build
      flush

      @io.pop
      write_end_tag

      # needed so the `write_cached` calls on ElementNode and RootNode won't add
      # anything else to the IO
      return ""
    end

    def ==(other)
      other.instance_variable_get("@io") == @io &&
      other.instance_variable_get("@element") == @element
    end

    # overriding this because the base Node class defines a 'to_s' method that
    # needs to be honored
    def to_str(*args)
      "Undies::ElementNode:#{self.object_id} @element=#{@element.inspect}"
    end
    alias_method :inspect, :to_str

    private

    def write_cached
      @io << @cached.to_s
    end

    def write_start_tag(newline='', level_offset=0)
      @io << "#{@io.line_indent(level_offset)}#{@element.__start_tag}#{newline}"
      @start_tag_written = true
    end

    def write_content
      @io << @element.__content
    end

    def write_end_tag(level_offset=0)
      if !@start_tag_written
        write_start_tag('', level_offset)
        write_content
        @io << "#{@element.__end_tag}#{@io.newline}"
      else
        @io << "#{@io.line_indent(level_offset)}#{@element.__end_tag}#{@io.newline}"
      end
    end

  end
end
