module Undies
  class Source

    attr_reader :file, :block, :data

    def initialize(file=nil, block=nil)
      if (file || block).nil?
        raise ArgumentError, "file or block required"
      end
      if block.nil? && !File.exists?(file)
        raise ArgumentError, "no template file '#{file}'"

      end

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
      !!@file && File.exists?(@file)
    end

  end
end