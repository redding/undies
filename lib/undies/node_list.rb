require "undies/node"

module Undies
  class NodeList < ::Array

    def initialize(*args)
      #always initialize empty
      super()
    end

    def append(node)
      self << node
      node
    end

    def <<(item)
      unless item.kind_of?(Node)
        raise ArgumentError, 'you can only append nodes to a NodeList'
      end
      super
    end

  end
end