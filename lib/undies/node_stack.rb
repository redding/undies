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

    attr_reader :stack, :cache, :buffer

    def initialize(output)
      @stack = []
      @cache = NodeStack::Cache.new(Proc.new do |item|
        self.using(item) do
          item.class.builds(item).each { |build| build.call }
        end
      end)
      @buffer = NodeStack::Buffer.new(output)
    end

    def empty?; @stack.empty?; end
    def size;   @stack.size;   end
    def first;  @stack.first;  end
    def last;   @stack.last;   end

    alias_method :current, :last
    alias_method :level, :size

    def push(node)
      @buffer.push(NodeStack::BufferItem.new(node, :start_tag, level))
      current.class.set_children(current, node.kind_of?(Element)) if current
      @stack.push(node)
    end

    def pop(*args)
      @cache.flush
      @buffer.push(NodeStack::BufferItem.new(current, :content, level))
      @stack.pop(*args).tap do |node|
        @buffer.push(NodeStack::BufferItem.new(node, :end_tag, level))
      end
    end

    def using(obj, &block)
      self.push(obj)
      (block || Proc.new {}).call
      self.pop
    end

    def node(node)
      @cache.push(node)
    end

    def flush
      @cache.flush
      @buffer.flush
    end

  end


  class NodeStack::Cache

    def initialize(callback_block)
      @flush_callback = callback_block || Proc.new {}
      @cache = []
    end

    def empty?; @cache.empty?; end
    def size;   @cache.size;   end
    def first;  @cache.first;  end
    def last;   @cache.last;   end

    def push(*args)
      flush
      @cache.push(*args)
    end

    def flush
      1.upto(@cache.size) { @flush_callback.call(@cache.shift) }
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
