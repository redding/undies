require "undies/source"

module Undies
  class SourceStack < ::Array

    # a source stack is used to manage which sources and any deeply nested
    # layouts they are in.  initialize this object with a content source obj
    # and get a stack where the the top source is the outer most layout and
    # the bottom source is the source used to initialize the stack (the content
    # source).  naturally any sources in between are the intermediate layouts
    # for the content source

    def initialize(source)
      if !source.kind_of?(Source)
        raise ArgumentError, "you must create a source stack from a source object"
      end
      super([source, source.layouts].flatten.compact)
    end

    def pop
      super
    end

  end
end
