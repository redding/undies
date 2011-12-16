module Undies

  class Node

    # have as many methods to the class level as possilbe to keep from
    # polluting the public instance methods and to maximize the effectiveness
    # of the Element#method_missing logic

    def self.content(node)
      node.instance_variable_get("@content")
    end

    def self.flush(output, node)
      if (c = self.content(node)).empty?
        output.pp_use_indent = true
      else
        output << c
      end
    end

    def initialize(content)
      @start_tag = nil
      @end_tag = nil
      @content = content
    end

    def ==(other_node)
      self.class.content(self) == other_node.class.content(other_node) &&
      self.instance_variable_get("@start_tag") == other_node.instance_variable_get("@start_tag") &&
      self.instance_variable_get("@end_tag") == other_node.instance_variable_get("@end_tag")
    end

  end
end
