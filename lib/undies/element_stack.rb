require "undies/element"

module Undies

  # TODO: don't need to subclass array if we aren't storing in memory
  class ElementStack < ::Array

    # an element stack is used to manage which element is receiving content
    # if an undies template is streaming io, then when an element is pushed,
    # its start tag is added to the stream and its end tag is added when popped.

    attr_reader :output

    def initialize(output, first_item=nil, *args)
      # reference the to output class being used to output rendered results
      @output = output
      # always initialize empty
      super()

      # apply any first_item
      self.send(:<<, first_item) if first_item
    end

    def push(item)
      unless item.kind_of?(Element)
        raise ArgumentError, 'you can only push element nodes to an ElementStack'
      end
      super
      self.output << item.class.start_tag(item)
      self.output.pp_level(:up)
      item
    end

    def pop
      item = super
      self.output.pp_level(:down)
      self.output << item.class.end_tag(item)
      item
    end

  end
end
