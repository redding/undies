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

    SELF_CLOSING_TAGS = [
      :area,
      :base, :br,
      :col,
      :embed,
      :frame,
      :hr,
      :img, :input,
      :link,
      :meta,
      :param
    ]

    SELF_CLOSING_TAGS.each do |tag|
      define_method("_#{tag}") do |*args, &build|
         __closed_element(tag, *args, &build)
      end
    end

    OPEN_TAGS = [
      :a, :abbr, :acronym, :address, :article, :aside, :audio,
      :b, :bdo, :big, :blockquote, :body, :button,
      :canvas, :caption, :center, :cite, :code, :colgroup, :command,
      :datalist, :dd, :del, :details, :dfn, :dialog, :div, :dl, :dt,
      :em,
      :fieldset, :figure, :footer, :form, :frameset,
      :h1, :h2, :h3, :h4, :h5, :h6, :head, :header, :hgroup, :html,
      :i, :iframe, :ins,
      :keygen, :kbd,
      :label, :legend, :li,
      :map, :mark, :meter,
      :nav, :noframes, :noscript,
      :object, :ol, :optgroup, :option,
      :p, :pre, :progress,
      :q,
      :ruby, :rt, :rp,
      :s, :samp, :script, :section, :select, :small, :source, :span, :strike, :strong, :style, :sub, :sup,
      :table, :tbody, :td, :textarea, :tfoot, :th, :thead, :time, :title, :tr, :tt,
      :u, :ul,
      :v, :video
    ]

    OPEN_TAGS.each do |tag|
      define_method("_#{tag}") do |*args, &build|
         __open_element(tag, *args, &build)
      end
    end

  end
end
