module Undies
  class Output

    attr_reader :io, :pp

    # the output class wraps an IO stream, gathers pretty printing options,
    # and handles pretty printing to the stream

    def initialize(io, opts={})
      @io = io
      self.options = opts
    end

    def options=(opts)
      if !opts.kind_of?(::Hash)
        raise ArgumentError, "please provide a hash to set options with"
      end

      @pp = opts[:pp]
      self.pp_level = 0
      #opts
    end

    def pp_level
      @pp_level
    end

    def pp_level=(value)
      @pp_indent = @pp ? "\n#{' '*value*@pp}" : ""
      @pp_level  = value
      #value
    end

    def <<(data)
      @io << "#{@pp_indent}#{data}"
    end

  end
end
