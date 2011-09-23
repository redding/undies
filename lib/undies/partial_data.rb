module Undies
  class PartialLocals < ::Hash

    attr_reader :path, :name

    def initialize(path)
      self.path = path
      super()
    end

    def path=(value)
      raise ArgumentError, "partial path required" if value.nil?
      @path = value
      @name = File.basename(@path.to_s).split(".").first.gsub(/^[^A-Za-z]+/, '')
    end

    def values=(value)
      raise ArgumentError if !value.kind_of?(::Hash)
      if value.has_key?(@name.to_sym)
        value[@name] = value.delete(@name.to_sym)
      end
      self.merge!(value)
    end

    def object=(value)
      if value
        self[@name] = value
      end
    end

  end
end
