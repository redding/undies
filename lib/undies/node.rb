module Undies

  class Node

    # have as many methods to the class level as possible to keep from
    # polluting the public instance methods and to maximize the effectiveness
    # of the Element#method_missing logic

    def __start_tag; @start_tag || ""; end
    def __end_tag; @end_tag || ""; end

    def __set_start_tag; end
    def __set_end_tag; end

    def __builds; @builds || []; end
    def __add_build(build_block); @builds << build_block; end

    def __children; @children; end
    def __set_children(value); @children = value; end

    def __attrs; @attrs; end
    def __merge_attrs(value={}); __attrs.merge!(value); end

    def __node_name; @name || ""; end
    def __content; @content || ""; end

    def __mode; @mode || :inline; end
    def __prefix(meth, level, indent)
      "".tap do |value|
        if __mode != :inline && indent > 0
          if meth == 'start_tag'
            value << "#{level > 0 ? "\n": ''}#{' '*level*indent}"
          elsif meth == 'end_tag'
            value << "\n#{' '*(level > 0 ? level-1 : level)*indent}"
          end
        end
      end
    end

    def initialize(content, mode=:inline)
      @start_tag = nil
      @end_tag = nil
      @content = content
      @builds = []
      @attrs = {}
      @children = false
      @mode = mode
    end

    def ==(other_node)
      __content   == other_node.__content   &&
      __start_tag == other_node.__start_tag &&
      __end_tag   == other_node.__end_tag
    end

  end
end
