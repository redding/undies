module Undies

  class NamedSource

    attr_reader :name
    attr_accessor :file, :opts, :proc

    def initialize(name, *args, &block)
      raise ArgumentError, "name must be a symbol" unless name.kind_of?(::Symbol)
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
      { :file => self.file,
        :opts => self.opts,
        :proc => self.proc
      }
    end

  end

  # singleton accessor for named sources

  def self.source(name, *args, &block)
    raise ArgumentError, "name must be a symbol" unless name.kind_of?(::Symbol)
    @@sources ||={}
    if args.empty? && block.nil?
      @@sources[name]
    else
      @@sources[name] = Undies::NamedSource.new(name, *args, &block)
    end
  end

end
