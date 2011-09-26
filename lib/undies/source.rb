module Undies
  class Source

    attr_reader :source, :data

    def initialize(source=nil)
      raise ArgumentError, "file or block required" if source.nil?

      @source = source
      if self.file? && !File.exists?(@source.to_s)
        raise ArgumentError, "no template file '#{@source}'"
      end

      # load source data and prepare (uses binread to avoid encoding issues)
      @data = if self.file?
        File.send(File.respond_to?(:binread) ? :binread : :read, @source.to_s)
      else
        @source
      end
    end

    def file?
      !@source.kind_of?(::Proc)
    end

  end
end
