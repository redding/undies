require "undies/node"

module Undies

  # a node list is an ordered collection of node data
  # * the Template class builds one as the template source is evaluated
  # * a list may contains nodes and/or other node lists
  # * serialize a list using 'to_s' using optional pretty printing args
  # * any pretty printing args are used to render the individual nodes/lists
  class NodeList < ::Array

    attr_reader :io

    def initialize(io=nil, *args)
      @io = io
      # always initialize empty
      super()
    end

    def append(node)
      self << node
      node
    end

    def <<(item)
      unless item.kind_of?(Node) || item.kind_of?(NodeList)
        raise ArgumentError, 'you can only append nodes or other node lists to a NodeList'
      end
      self.io << item.to_s if self.io && !item.kind_of?(Element)
      super
    end

    def to_s(pp_level=0, pp_indent=nil)
      self.collect{|n| n.to_s(pp_level, pp_indent)}.join
    end

  end

end
