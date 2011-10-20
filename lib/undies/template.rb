require 'undies/render_data'

module Undies
  class Template

    # have as many methods to the class level as possilbe to keep from
    # polluting the public instance methods, the instance scope, and to
    # maximize the effectiveness of the Template#method_missing logic

    def self.render_data(t, *args)
      @template_rd ||= {}
      args.size > 0 ? @template_rd[t] = args.first : @template_rd[t]
    end

    def initialize(source, data={}, opts={})
      # setup the render data
      self.class.render_data(self, RenderData.new(source, opts))

      # apply data to template scope
      raise ArgumentError if !data.kind_of?(::Hash)
      if (data.keys.collect(&:to_s) & self.public_methods.collect(&:to_s)).size > 0
        raise ArgumentError, "data conflicts with template public methods."
      end
      metaclass = class << self; self; end
      data.each {|key, value| metaclass.class_eval { define_method(key){value} }}

      # yield to recursivley render the source stack
      self.__yield

      # TODO: teardown the render data to prevent memory leaks
      #self.class.render_data(self, nil)
    end

    # call this to render the templates source
    # use this method in layouts to insert a layout's content source
    def __yield
      return if (rd = self.class.render_data(self)).nil? || (source = rd.source_stack.pop).nil?
      if source.file?
        instance_eval(source.data, source.source, 1)
      else
        instance_eval(&source.data)
      end
    end

    def to_s; self.class.render_data(self).output; end

    # Add a text node (data escaped) to the nodes of the current node
    def _(data=""); self.__ self.escape_html(data.to_s); end

    # Add a text node with the data un-escaped
    def __(data=""); self.class.render_data(self).node(data.to_s); end

    # Add an element to the nodes of the current node
    def element(*args, &block); self.class.render_data(self).element(*args, &block); end
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

  end
end
