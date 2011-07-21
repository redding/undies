require 'undies/source'
require 'undies/buffer'
require 'undies/tag'

module Undies
  class Template < Buffer

    def initialize(file=nil, &block)
      super
      @source = Source.new(file, block)
    end

    def to_s(pretty_print=false)
      evaluate_source
      super(pretty_print)
    end

    protected

    def evaluate_source
      if @source.file?
        instance_eval(@source.data, @source.file, 1)
      else
        instance_eval(&@source.data)
      end
    end

  end
end
