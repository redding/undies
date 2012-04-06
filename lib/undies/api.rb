require 'undies/raw'
require 'undies/element_node'
require 'undies/element'

module Undies

  module API

    # capture methods

    def raw(string)
      Raw.new(string)
    end

    # streaming methods

    # Add a text node (data escaped) to the nodes of the current node
    def _(data="")
      @_undies_io.current.text(self.class.escape_html(data.to_s))
    end

    # stream an open element
    def __open_element(name, *args, &build)
      @_undies_io.
        current.
        element_node(ElementNode.new(@_undies_io, Element::Open.new(name, *args, &build))).
        element
    end
    alias_method :__open_tag, :__open_element
    alias_method :__element,  :__open_element
    alias_method :__tag,      :__open_element

    # stream an open element
    def __closed_element(name, *args, &build)
      @_undies_io.
        current.
        element_node(ElementNode.new(@_undies_io, Element::Closed.new(name, *args, &build))).
        element
    end
    alias_method :__closed_tag, :__closed_element

    def _html(*args, &build); __open_element(:html, *args, &build); end
    def _head(*args, &build); __open_element(:head, *args, &build); end
    def _body(*args, &build); __open_element(:body, *args, &build); end
    def _span(*args, &build); __open_element(:span, *args, &build); end
    def _div(*args, &build);  __open_element(:div,  *args, &build); end
    def _br(*args, &build);   __closed_element(:br,   *args, &build); end

  end
end
