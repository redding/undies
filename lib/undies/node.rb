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
      [start_tag.to_s, content.to_s, end_tag.to_s].compact.join
    end

  end
end