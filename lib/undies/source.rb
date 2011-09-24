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

    def markup
      self.block || self.file_data
    end

    def layout?
      !!(self.block && self.file)
    end

    def file_data
      File.send(File.respond_to?(:binread) ? :binread : :read, self.file) if self.file
    end

  end
end
