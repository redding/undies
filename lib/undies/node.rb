module Undies

  class Node

    # moving as many methods to the class level as possilbe to keep from
    # polluting the public instance methods and to maximize the effectiveness
    # of the Element#method_missing logic

    def self.content(node)
      node.instance_variable_get("@content")
    end

    def self.start_tag(node); nil; end
    def self.end_tag(node);   nil; end

    def initialize(content)
      @content = content
    end

    def to_s(pp_level=0, pp_indent=nil)
      [ self.class.start_tag(self),
        self.class.content(self),
        self.class.end_tag(self)
      ].compact.map do |item|
        if item.kind_of? NodeList
          item.to_s(pp_level+1, pp_indent)
        else
          pp_indent ? "#{' '*pp_level*pp_indent}#{item}\n" : item.to_s
        end
      end.join
    end

  end
end
