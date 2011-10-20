require 'undies/renderer'
require 'undies/node'
require 'undies/element'

module Undies
  class Template

    # prefixing with a triple underscore to not pollut metaclass locals scope

    def initialize(source, data={}, opts={})
      # setup the renderer
      @___renderer___ = Renderer.new(source, opts)

      # apply data to template scope
      if !data.kind_of?(::Hash)
        raise ArgumentError
      end
      if (data.keys.collect(&:to_s) & self.public_methods.collect(&:to_s)).size > 0
        raise ArgumentError, "data conflicts with template public methods."
      end
      metaclass = class << self; self; end
      data.each do |key, value|
        metaclass.class_eval do
          define_method(key) { value }
        end
      end

      # yield to recursivley render the source stack
      self.__yield
    end

    # call this to render the templates source
    # use this method in layouts to insert a layout's content source
    def __yield
      if source = self.___renderer___.source_stack.pop
        if source.file?
          instance_eval(source.data, source.source, 1)
        else
          instance_eval(&source.data)
        end
      end
    end

    # TODO: this may be obsolete if move to a full streaming implementation
    def to_s
      self.___renderer___.to_s
    end

    # Add a text node (data escaped) to the nodes of the current node
    def _(data="")
      self.__ self.escape_html(data.to_s)
    end

    # Add a text node with the data un-escaped
    def __(data="")
      node = Node.new(data.to_s)
      self.___renderer___.append(node)
    end

    # Add an element to the nodes of the current node
    def element(name, attrs={}, &block)
      node = Element.new(self.___renderer___.element_stack, name, attrs, &block)
      self.___renderer___.append(node)
    end
    alias_method :tag, :element

    # Element proxy methods ('_<element>'') ========================
    ELEM_METH_REGEX = /^_(.+)$/

    def method_missing(meth, *args, &block)
      if meth.to_s =~ ELEM_METH_REGEX
        element($1, *args, &block)
      else
        super
      end
    end

    def respond_to?(*args)
      if args.first.to_s =~ ELEM_METH_REGEX
        true
      else
        super
      end
    end
    # ==============================================================

    # Ripped from Rack v1.3.0 ======================================
    # => ripped b/c I don't want a dependency on Rack for just this
    ESCAPE_HTML = {
      "&" => "&amp;",
      "<" => "&lt;",
      ">" => "&gt;",
      "'" => "&#x27;",
      '"' => "&quot;",
      "/" => "&#x2F;"
    }
    ESCAPE_HTML_PATTERN = Regexp.union(*ESCAPE_HTML.keys)

    # Escape ampersands, brackets and quotes to their HTML/XML entities.
    def escape_html(string)
      string.to_s.gsub(ESCAPE_HTML_PATTERN){|c| ESCAPE_HTML[c] }
    end
    # end Rip from Rack v1.3.0 =====================================

    protected

    # wrapping non-public methods with a triple underscore to not pollute
    # template data data scope

    def ___renderer___
      @___renderer___
    end

  end
end
