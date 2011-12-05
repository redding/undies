module Undies

  class NodeBuffer < ::Array

    # a node buffer is a FIFO used to, well, buffer node data for output.
    # nodes are pushed on the stack for processing and flushed to output
    # when pulled.  empty the buffer by flushing it to output.

    # the buffer allows for dynamic node handling while limiting memory
    # bloat.  the Output handler ensures that only 1 node is buffered
    # in memory at any given time by pulling the previous node to output
    # before pushing the next node for processing.

    def initialize(*args)
      # always initialize empty
      super()
    end

    def push(node)
      super
      node
    end

    def pull(output)
      if (node = self.shift)
        node.class.flush(output, node)
      end
    end

    def flush(output)
      self.pull(output) while self.size > 0
    end

  end
end
