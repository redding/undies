module Undies

  class Node

    # have as many methods to the class level as possible to keep from
    # polluting the public instance methods and to maximize the effectiveness
    # of the Element#method_missing logic

    def self.start_tag(node)
      node.instance_variable_get("@start_tag") || ""
    end

    def self.end_tag(node)
      node.instance_variable_get("@end_tag") || ""
    end

    def self.set_start_tag(node); end
    def self.set_end_tag(node); end

    def self.node_name(node)
      node.instance_variable_get("@name") || ""
    end

    def self.attrs(element)
      element.instance_variable_get("@attrs")
    end

    def self.set_attrs(element, value={})
      attrs(element).merge(value).tap do |a|
        element.instance_variable_set("@attrs", a)
      end
    end

    def self.content(node)
      node.instance_variable_get("@content") || ""
    end

    def self.builds(node)
      node.instance_variable_get("@builds") || []
    end

    def self.children(node)
      node.instance_variable_get("@children")
    end

    def self.set_children(node, value)
      node.instance_variable_set("@children", value)
    end

    def self.mode(node)
      node.instance_variable_get("@mode") || :inline
    end

    def self.prefix(node, meth, level, indent)
      "".tap do |value|
        if mode(node) != :inline && indent > 0
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
      self.class.content(self) == other_node.class.content(other_node) &&
      self.instance_variable_get("@start_tag") == other_node.instance_variable_get("@start_tag") &&
      self.instance_variable_get("@end_tag") == other_node.instance_variable_get("@end_tag")
    end

  end
end
