module Undies

  class Node

    # have as many methods to the class level as possilbe to keep from
    # polluting the public instance methods and to maximize the effectiveness
    # of the Element#method_missing logic

    def self.content(node)
      node.instance_variable_get("@content")
    end

    def self.flush(output, node)
      self.content(node).tap do |c|
        output.pp_use_indent = true if node.force_pp?
        output << c
      end
    end

    def initialize(content, opts={})
      @start_tag = nil
      @end_tag = nil
      @force_pp = opts[:force_pp]
      @content = content
    end

    def force_pp?
      !!@force_pp
    end

    def ==(other_node)
      self.class.content(self) == other_node.class.content(other_node) &&
      self.instance_variable_get("@start_tag") == other_node.instance_variable_get("@start_tag") &&
      self.instance_variable_get("@end_tag") == other_node.instance_variable_get("@end_tag")
    end

  end
end
