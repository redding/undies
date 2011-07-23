require 'undies/template'

module Undies
  class Partial < Template

    attr_reader :name, :locals

    def initialize(path, o=nil, l={})
      super(path)
      self.object, self.locals = parse_opts(o, l)
    end

    def name
      @name ||= File.basename(self.source.file.to_s).split(".").first.gsub(/^[^A-Za-z]+/, '')
    end

    protected

    def object=(value)
      @locals ||= {}
      if value
        @locals[self.name.to_sym] = value
      end
    end

    def locals=(value)
      raise ArgumentError if !value.kind_of?(::Hash)
      @locals ||= {}
      @locals.merge!(value)
    end

    private

    def parse_opts(o, l)
      o && o.kind_of?(::Hash) ? [nil, o] : [o, l]
    end

  end
end
