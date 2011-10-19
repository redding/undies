module Undies
  class Node

    # wrapping as many public methods as possible in triple underscore to not
    # pollute the public scope.  trying to make the element class's method
    # missing as effective as possible.

    def initialize(content)
      @content = content
    end

    def ___content___;   @content; end
    def ___start_tag___; nil;      end
    def ___end_tag___;   nil;      end

    def to_s(pp_level=0, pp_indent=nil)
      [ self.___start_tag___,
        self.___content___,
        self.___end_tag___
      ].compact.collect do |item|
        if item.kind_of? NodeList
          item.to_s(pp_level+1, pp_indent)
        else
          pp_indent ? "#{' '*pp_level*pp_indent}#{item}\n" : item.to_s
        end
      end.join
    end

  end
end
