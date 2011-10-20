require 'undies/partial_locals'
require 'undies/template'

module Undies
  module PartialTemplate

    def initialize(path, *args)
      locals = PartialLocals.new(path)
      options, locals.values, locals.object = [
        args[-1].kind_of?(::Hash) && args[-2].kind_of?(::Hash) ? args.pop : {},
        args.last.kind_of?(::Hash) ? args.pop : {},
        args.first
      ]
      super(Undies::Source.new(path), locals, options)
    end

  end
end
