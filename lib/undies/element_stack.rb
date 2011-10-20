require "undies/element"

module Undies
  class ElementStack < ::Array

    # an element stack is used to manage which element is receiving content
    # if an undies template is streaming io, then when an element is pushed,
    # its start tag is added to the stream and its end tag is added when popped.

    attr_reader :io

    def initialize(first_item=nil, io=nil, *args)
      @io = io
      # always initialize empty
      super()
      self.send(:<<, first_item) if first_item
    end

    def push(item)
      unless item.kind_of?(Element)
        raise ArgumentError, 'you can only push element nodes to an ElementStack'
      end
      super
      @io << item.___start_tag___ if @io
      item
    end

    def pop
      item = super
      @io << item.___end_tag___ if @io
      item
    end

  end
end
