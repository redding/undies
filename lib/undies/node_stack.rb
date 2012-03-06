module Undies
  class NodeStack

    class Cache; end
    class BufferItem; end
    class Buffer; end

    # a node stack handles buffering nodes for output. I want to treat this
    # as a stack of nodes for the template API to reference.  I need to push
    # a node onto the stack, reference it using the 'current' method,
    # and pop it off the stack when I'm done.

    # the stack first caches new nodes before pushing them onto the stack
    # node output is buffered as new nodes are pushed

    def self.create(output)
      output.kind_of?(NodeStack) ? output : NodeStack.new(output)
    end

    attr_reader :stack, :buffer
    attr_accessor :cached_node

    def initialize(output)
      @stack = []
      @cached_node = nil
      @buffer = NodeStack::Buffer.new(output)
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
        current.class.set_children(current, node.kind_of?(Element))
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
      @buffer.flush
    end

    def clear_cached
      node_to_push, self.cached_node = self.cached_node, nil
      if node_to_push
        push(node_to_push)
        node_to_push.class.builds(node_to_push).each { |build| build.call }
        clear_cached
        pop
      end
    end

    private

    def open(node)
      # puts "open node: #{node.inspect}";
      @buffer.push(BufferItem.new(node, :start_tag, @written_level))
      @written_level += 1
      @buffer.push(BufferItem.new(node, :content, @written_level))
    end

    def write(node)
      # puts "write node: #{node.inspect}";
      @buffer.push(BufferItem.new(node, :start_tag, @written_level))
      @buffer.push(BufferItem.new(node, :content, @written_level+1))
      @buffer.push(BufferItem.new(node, :end_tag, @written_level))
    end

    def close(node)
      # puts "close node: #{node.inspect}";
      @written_level -= 1
      @buffer.push(BufferItem.new(node, :end_tag, @written_level))
    end

  end


  class NodeStack::BufferItem

    attr_reader :item
    attr_accessor :write_method, :level

    def initialize(item, write_method, level=0)
      @item = item
      @write_method = write_method.to_s
      @level = level || 0
    end

    def prefix(pp, pp_level)
      @item.class.send(:prefix, @item, @write_method, @level+pp_level, pp)
    end

    def to_s
      @item.class.send(@write_method, @item)
    end

  end


  class NodeStack::Buffer

    attr_reader :output

    def initialize(output)
      @output = output
      @buffer = []
    end

    def empty?; @buffer.empty?; end
    def size;   @buffer.size;   end
    def first;  @buffer.first;  end
    def last;   @buffer.last;   end

    alias_method :current, :first

    def push(item)
      self.flush
      @buffer.push(item)
    end

    def flush
      1.upto(@buffer.size) { @output.write(@buffer.shift) }
    end

  end


end
