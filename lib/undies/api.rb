require 'undies/element_node'
require 'undies/element'

module Undies

  module API

    # HTML tag helpers

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

    # capture methods

    def raw(string)
      Raw.new(string)
    end

    def open_element(name, *args)
      Raw.new(Element::Open.new(name, *args).to_s)
    end
    alias_method :open_tag, :open_element
    alias_method :element,  :open_element
    alias_method :tag,      :open_element

    def closed_element(name, *args)
      Raw.new(Element::Closed.new(name, *args).to_s)
    end
    alias_method :closed_tag, :closed_element

    SELF_CLOSING_TAGS.each do |tag|
      define_method(tag){ |*args| closed_element(tag, *args, &build) }
    end

    OPEN_TAGS.each do |tag|
      define_method(tag){ |*args| open_element(tag, *args) }
    end

    # streaming methods

    # Add a text node (data escaped) to the nodes of the current node
    def _(data="")
      @_undies_io.current.text(self.class.escape_html(data.to_s))
    end

    def __open_element(name, *args, &build)
      @_undies_io.
        current.
        element_node(ElementNode.new(@_undies_io, Element::Open.new(name, *args, &build))).
        element
    end
    alias_method :__open_tag, :__open_element
    alias_method :__element,  :__open_element
    alias_method :__tag,      :__open_element

    def __closed_element(name, *args, &build)
      @_undies_io.
        current.
        element_node(ElementNode.new(@_undies_io, Element::Closed.new(name, *args, &build))).
        element
    end
    alias_method :__closed_tag, :__closed_element

    SELF_CLOSING_TAGS.each do |tag|
      define_method("_#{tag}") do |*args, &build|
        __closed_element(tag, *args, &build)
      end
    end

    OPEN_TAGS.each do |tag|
      define_method("_#{tag}") do |*args, &build|
        __open_element(tag, *args, &build)
      end
    end

    # Manual Builder methods

    # call this method to manually push the current scope to the previously
    # cached element (if any)
    # - changes the context of template method calls to operate on that element
    def __push
      @_undies_io.current.push
    end

    # call this method to manually pop the current scope to the previous scope
    # - changes the context of template method calls to operate on the parent
    #   element or root node
    def __pop
      @_undies_io.current.pop
    end

    # call this to manually flush a template
    def __flush
      @_undies_io.current.flush
    end

    # call this to modify element attrs inside a build block.  Once content
    # or child elements have been added, any '__attr' directives will
    # be ignored b/c the elements start_tag has already been flushed
    # to the output
    def __attrs(attrs_hash={})
      @_undies_io.current.attrs(attrs_hash)
    end

    # Source handling methods

    # call this to render template source
    # use this method in layouts to insert a layout's content source
    def __yield
      return if (source = @_undies_source_stack.pop).nil?
      if source.file?
        instance_eval(source.data, source.source, 1)
      else
        instance_eval(&source.data)
      end
    end

    # call this to render partial source embedded in a template
    # partial source is rendered with its own scope/data but shares
    # its parent template's output object
    def __partial(source, data={})
      if source.kind_of?(Source)
        Undies::Template.new(source, data, @_undies_io)
      else
        @_undies_io.current.partial(source.to_s)
      end
    end

  end
end
