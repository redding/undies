module Undies
  class NodeStack

    # the node stack handles caching nodes for processing, running node
    # builds, and buffering node output for writing. I want to treat this
    # as a stack of nodes for the template API to reference.  I need to push
    # a node onto the stack, reference it using the 'current' method,
    # and pop it off the stack when I'm done.

    # the stack first caches new nodes before pushing them onto the stack
    # and node output is buffered as new nodes are pushed

    def self.create(output)
      output.kind_of?(NodeStack) ? output : NodeStack.new(output)
    end

    attr_reader :stack, :output, :buffer
    attr_accessor :cached_node

    def initialize(output)
      @stack = []
      @cached_node = nil
      @output = output
      @written_level = 0
    end

    def empty?; @stack.empty?; end
    def size;   @stack.size;   end
    def first;  @stack.first;  end
    def last;   @stack.last;   end

    alias_method :current, :last
    alias_method :level, :size

    def push(node)
      if current
        current.__set_children(node.kind_of?(Element))
      end
      if @written_level < level
        open(current)
      end
      @stack.push(node)
    end

    def pop(*args)
      if !empty?
        node = if @written_level < level
          @stack.pop.tap { |node| write(node) }
        else
          @stack.pop.tap { |node| close(node) }
        end
      end
    end

    def node(node)
      clear_cached
      self.cached_node = node
    end

    def flush
      clear_cached
    end

    def clear_cached
      node_to_push, self.cached_node = self.cached_node, nil
      if node_to_push
        push(node_to_push)
        node_to_push.__builds.each { |build| build.call }
        clear_cached
        pop
      end
    end

    private

    def open(node)
      start_tag(node, @written_level)
      @written_level += 1
      content(node, @written_level)
    end

    def write(node)
      start_tag(node, @written_level)
      content(node, @written_level+1)
      end_tag(node, @written_level)
    end

    def close(node)
      @written_level -= 1
      end_tag(node, @written_level)
    end

    # TODO: Fill up an output write buffer with arg arrays
    # then empty it

    def start_tag(node, level)
      @output.write(node, 'start_tag', level)
    end

    def content(node, level)
      @output.write(node, 'content', level)
    end

    def end_tag(node, level)
      @output.write(node, 'end_tag', level)
    end

  end


end
