require 'undies/source'
require 'undies/buffer'
require 'undies/tag'

module Undies
  class Template < Buffer

    def initialize(file=nil, &block)
      super
      if (@source = Source.new(file, block)).file?
        instance_eval(@source.data, @source.file, 1)
      else
        instance_eval(&@source.data)
      end
    end

    def to_s(pp_indent=nil)
      super(0, pp_indent)
    end

  end
end
