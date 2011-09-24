module Undies
  class Source

    attr_reader :file, :block #:source, :data

    def initialize(file=nil, &block)
      raise ArgumentError, "file or block required" if file.nil? && block.nil?
      if !file.nil? && !File.exists?(file)
        raise ArgumentError, "source file does not exist"
      end
      @file = file
      @block = block
    end

  end
end
