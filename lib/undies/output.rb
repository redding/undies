module Undies
  class Output

    attr_reader :io, :pp, :node_stack

    # the output class wraps an IO stream, gathers pretty printing options,
    # and handles pretty printing to the stream

    def initialize(io, opts={})
      @io = io
      self.options = opts
      @node_stack = NodeStack.new(self)
    end

    def options=(opts)
      if !opts.kind_of?(::Hash)
        raise ArgumentError, "please provide a hash to set options with"
      end

      @pp = opts[:pp]
      self.pp_level = 0
    end

    def pp_level
      @pp_level
    end

    def pp_level=(value)
      @pp_indent = @pp ? "\n#{' '*value*@pp}" : ""
      @pp_level  = value
    end

    def <<(data)
      @io << "#{@pp_indent}#{data}"
    end

    def node(data="")
      self.flush
      self.node_stack.push(Node.new(data))
    end

    def element(name, attrs={}, &block)
      self.flush
      self.node_stack.push(Element.new(name, attrs, &block))
    end

    def flush
      self.node_stack.pop
    end

  end
end
