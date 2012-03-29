module Undies
  class IO

    # the IO class wraps a stream (anything that responds to '<<' and
    # gathers streaming options options.  handles writing markup to the
    # stream.

    attr_reader :stream, :indent, :newline, :node_stack
    attr_accessor :level

    def initialize(stream, opts={})
      @stream = stream
      @node_stack = []
      self.options = opts
    end

    def options=(opts)
      if !opts.kind_of?(::Hash)
        raise ArgumentError, "please provide a hash to set IO options"
      end

      @indent = opts[:pp] || 0
      @newline = opts[:pp].nil? ? "" : "\n"
      @level = opts[:level] || 0
    end

    def line_indent(relative_level=0)
      "#{' '*(@level+relative_level)*@indent}"
    end

    # TODO: threaded/forked writing for performance improvement
    def <<(markup)
      @stream << markup
    end

    def push(scope); @level += 1; push!(scope); end
    def push!(scope); @node_stack.push(scope); end
    def pop; @level -= 1; @node_stack.pop; end
    def current; @node_stack.last; end
    def empty?; @node_stack.empty? end

  end
end
