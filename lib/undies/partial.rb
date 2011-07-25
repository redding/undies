require 'undies/partial_data'
require 'undies/template'

module Undies
  class Partial < Template

    def initialize(path, object=nil, locals={})
      data = PartialData.new(path)
      data.object, data.values = object_locals(object, locals)
      super(path, data)
    end

    private

    def object_locals(o, l)
      o && o.kind_of?(::Hash) ? [nil, o] : [o, l || {}]
    end

  end
end
