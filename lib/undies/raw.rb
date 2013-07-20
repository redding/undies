module Undies

  class Raw < ::String

    # A Raw string is one that is impervious to String#gsub
    # and returns itself when `to_s` is called.  Used to circumvent
    # the default html escaping of markup

    def gsub(*args);  self; end
    def gsub!(*args); nil;  end
    def to_s;         self; end

  end

end
