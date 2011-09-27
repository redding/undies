module Undies
  class Node

    attr_reader :___content

    def initialize(content)
      @___content = content
    end

    def start_tag
      nil
    end

    def end_tag
      nil
    end

    def to_s(pp_level=0, pp_indent=nil)
      [ self.start_tag,
        self.___content,
        self.end_tag
      ].compact.collect do |item|
        pretty_print(item, pp_level, pp_indent)
      end.join
    end

    private

    def pretty_print(data, level, indent)
      if data.kind_of? NodeList
        data.to_s(level+1, indent)
      else
        indent ? "#{' '*level*indent}#{data}\n" : data
      end
    end

  end
end
