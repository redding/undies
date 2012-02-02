module Undies
  class Output

    # the output class wraps an IO stream, gathers pretty printing options,
    # and handles writing out buffered node stack items

    attr_reader :io, :pp
    attr_accessor :pp_level

    def initialize(io, opts={})
      @io = io
      self.options = opts
    end

    def options=(opts)
      if !opts.kind_of?(::Hash)
        raise ArgumentError, "please provide a hash to set options with"
      end

      # setup any pretty printing
      @pp = opts[:pp] || 0
      @pp_level  = opts[:pp_level] || 0
    end

    def write(item)
      if !(value = item.to_s).empty?
        "#{item.prefix(@pp, @pp_level)}#{value}".tap { |data| @io << data }
      end
    end

  end
end
