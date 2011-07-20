module Undies
  class Source

    attr_reader :file, :block, :data

    def initialize(file=nil, block=nil)
      raise ArgumentError, "file or block required" if (file || block).nil?

      @file = file
      @block = block

      # load template data and prepare (uses binread to avoid encoding issues)
      @data = @block || if File.respond_to?(:binread)
        File.binread(@file)
      else
        File.read(@file)
      end
    end

    def file?
      !!self.file
    end

  end
end