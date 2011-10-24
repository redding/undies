require 'undies/partial_locals'
require 'undies/template'

module Undies
  module PartialTemplate

    # Mixin this in to a template class to provide a partial template constructor
    # api.  The difference is that a PartialTemplate is always constructed with
    # file source, and can optionally be passed a data object that will be given
    # to the template named after the partial file.

    def initialize(path, *args)
      raise "please provide an Output object" unless args.last.kind_of?(Output)
      output = args.pop
      locals = PartialLocals.new(path)
      locals.values, locals.object = [
        args.last.kind_of?(::Hash) ? args.pop : {},
        args.first
      ]
      super(Undies::Source.new(path), locals, output)
    end

  end
end
