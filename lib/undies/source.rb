module Undies
  class Source

    attr_reader :source, :data, :layout

    def initialize(*args, &block)
      named = args.first.kind_of?(::Symbol) ? args.first : nil
      args << block if block
      # TODO: retrieve named source args
      self.args = named ? Undies.source(named).args : args
    end

    def file?
      !@source.kind_of?(::Proc)
    end

    def layouts
      if layout
        [self.layout, self.layout.layouts].flatten.compact
      else
        []
      end
    end

    def layout_sources
      self.layouts.collect{|l| l.source}
    end

    def ==(other_source)
      self.source == other_source.source &&
      self.layout_sources == other_source.layout_sources
    end

    def args=(values)
      block, opts, path = [
        values.last.kind_of?(::Proc)   ? values.pop : nil,
        values.last.kind_of?(::Hash)   ? values.pop : {},
        values.last.kind_of?(::String) ? values.pop : nil
      ]

      self.source = path || block
      self.layout = opts[:layout]
    end

    def source=(value)
      if value.nil?
        raise ArgumentError, "source name, file, or block required"
      end
      @data = if value.kind_of?(::Proc)
        value
      else
        raise ArgumentError, "no source file '#{value}'" if !File.exists?(value.to_s)
        File.send(File.respond_to?(:binread) ? :binread : :read, value.to_s)
      end
      @source = value
    end

    def layout=(value)
      @layout = case value
      when Source, NilClass
        value
      when ::Proc
        Source.new(&value)
      when ::String
        Source.new(value)
      # TODO:
      # when ::Symbol
      #   Source.new(Undies.source(value).args)
      else
        raise ArgumentError, "invalid layout"
      end
    end

  end
end
