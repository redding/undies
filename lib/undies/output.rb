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

      @pp_level  = 0
      @pp = opts[:pp]
    end

    def pp_level(action=nil, amount=1)
      case action
      when :up
        @pp_level += amount
      when :down
        @pp_level -= amount
      when :reset
        @pp_level = 0
      else
        @pp_level
      end
    end

    def <<(data)
      # puts
      # puts data.inspect
      # puts "-------------"
      # puts caller.join("\n")
      # puts
      @io << (@pp ? "#{' '*@pp_level*@pp}#{data}\n" : data.to_s)
    end

  end
end
