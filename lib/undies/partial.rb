require 'undies/template'

module Undies
  class Partial < Template

    attr_reader :name, :locals

    def initialize(path, object=nil, locals = {})
      self.object = object
      self.locals = locals.dup
      super(path)
    end

    def name
      @name ||= File.basename(self.source.file.to_s)#.split(".").first.gsub(/^[^A-z]+/).to_sym
    end

    protected

    def object=(value)
      @locals ||= {}
      @locals[self.name] = value
    end

    def locals=(value)
      raise ArgumentError unless value.kind_of?(::Hash)
      @locals ||= {}
      @locals.merge!(value)
    end

  end
end
