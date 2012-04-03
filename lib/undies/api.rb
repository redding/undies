require 'undies/raw'

module Undies
  module API

    # capture methods

    def raw(string)
      Raw.new(string)
    end

    # streaming methods

    # Add a text node (data escaped) to the nodes of the current node
    def _(data="")
      @_undies_io.current.__text(self.class.escape_html(data.to_s))
    end

    # Add an element to the node stack
    def __element(*args, &build)
      @_undies_io.current.__element(ElementNode.new(@_undies_io, *args, &build))
    end
    alias_method :__tag, :__element

    def _html(*args, &build); __element(:html, *args, &build); end
    def _head(*args, &build); __element(:head, *args, &build); end
    def _body(*args, &build); __element(:body, *args, &build); end
    def _span(*args, &build); __element(:span, *args, &build); end
    def _div(*args, &build);  __element(:div,  *args, &build); end
    def _br(*args, &build);   __element(:br,   *args, &build); end

  end
end
