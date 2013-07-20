module Undies



  class Source

    attr_reader :source, :data, :layout

    def initialize(*args, &block)
      named = args.first.kind_of?(NamedSource) ? args.first : nil
      args << block if block
      self.args = named ? named.args.compact : args
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
      proc, opts, file = [
        values.last.kind_of?(::Proc)   ? values.pop : nil,
        values.last.kind_of?(::Hash)   ? values.pop : {},
        values.last.kind_of?(::String) ? values.pop : nil
      ]

      self.source = file || proc
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
      when ::String, NamedSource
        Source.new(value)
      else
        raise ArgumentError, "invalid layout"
      end
    end

  end



  class NamedSource

    attr_accessor :file, :opts, :proc

    def initialize(*args, &block)
      args << block if block
      self.args = args
    end

    def ==(other_named_source)
      self.file == other_named_source.file &&
      self.opts == other_named_source.opts &&
      self.proc == other_named_source.proc
    end

    def args=(values)
      self.proc, self.opts, self.file = [
        values.last.kind_of?(::Proc)   ? values.pop : nil,
        values.last.kind_of?(::Hash)   ? values.pop : {},
        values.last.kind_of?(::String) ? values.pop : nil
      ]
    end

    def args
      [self.file, self.opts, self.proc]
    end

  end

  # singleton accessors for named sources

  def self.named_sources
    @@sources ||= {}
  end

  def self.named_source(name, *args, &block)
    if args.empty? && block.nil?
      self.named_sources[name]
    else
      self.named_sources[name] = Undies::NamedSource.new(*args, &block)
    end
  end

  def self.source(name)
    if ns = self.named_source(name)
      Undies::Source.new(ns)
    end
  end



  class SourceStack < ::Array

    # a source stack is used to manage which sources and any deeply nested
    # layouts they are in.  initialize this object with a content source obj
    # and get a stack where the the top source is the outer most layout and
    # the bottom source is the source used to initialize the stack (the content
    # source).  naturally any sources in between are the intermediate layouts
    # for the content source

    def initialize(source)
      super([source, source.layouts].flatten.compact)
    end

    def pop
      super
    end

  end



end
