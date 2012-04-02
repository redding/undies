module Undies
  class Raw < ::String

    # A Raw string is one that is impervious to String#gsub and returns itself
    # when `to_s` is called.

    def gsub(*args, &block)
      self
    end

    def gsub!(*args, &block)
      nil
    end

    def to_s
      self
    end

  end
end
