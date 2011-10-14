require 'undies/partial_locals'
require 'undies/template'

module Undies
  module PartialTemplate

    def initialize(path, *args)
      locals = PartialLocals.new(path)
      locals.values, io, locals.object = self.___partial_args(*args)
      super(path, io, locals)
    end

    protected

    def ___partial_args(*args)
      [ args.last.kind_of?(::Hash) ? args.pop : {},
        self.___is_a_stream?(args.last) ? args.pop : nil,
        args.first
      ]
    end

  end
end
