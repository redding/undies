require "undies/node"

module Undies

  # TODO: don't need to subclass array if we aren't storing in memory
  class NodeList < ::Array

    attr_reader :output

    def initialize(output, *args)
      # reference the to output class being used to output rendered results
      @output = output
      # always initialize empty
      super()
    end

    def append(node)
      self << node
      node
    end

    # TODO: this won't be necessary (move to append method) once we stop storing in memory
    def <<(item)
      unless item.kind_of?(Node) || item.kind_of?(NodeList)
        raise ArgumentError, 'you can only append nodes or other node lists to a NodeList'
      end

      # don't output elements when they are pushed b/c the element stack handles their output
      self.output << item.to_s if !item.kind_of?(Element)
      super
    end

  end

end
