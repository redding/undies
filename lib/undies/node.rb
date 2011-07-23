module Undies
  class Node

    attr_reader :content

    def initialize(content)
      @content = content
    end

    def start_tag
      nil
    end

    def end_tag
      nil
    end

    def to_s(pp_indent=nil)
      [start_tag, content, end_tag].compact.join
    end

  end
end