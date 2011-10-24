module Undies

  class NodeStack < ::Array

    # a node stack is used to manage streaming node content to some output.
    # nodes are pushed on the stack for processing and flushed when popped.

    attr_reader :output

    def initialize(output, *args)
      @output = output
      # always initialize empty
      super()
    end

    def push(item)
      super
      item
    end

    def pop
      if self.size > 0
        self.flush(item = super)
        item
      end
    end

    def flush(item)
      item.class.flush(item, self)
    end

  end
end
