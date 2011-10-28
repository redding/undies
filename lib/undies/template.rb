require 'undies/source_stack'
require 'undies/output'

module Undies
  class Template

    # have as many methods to the class level as possilbe to keep from
    # polluting the public instance methods, the instance scope, and to
    # maximize the effectiveness of the Template#method_missing logic

    def self.output(template)
      template.instance_variable_get("@_undies_output")
    end

    def initialize(source, data, output)
      # setup the source stack and output objects
      raise ArgumentError, "please provide a Source object" if !source.kind_of?(Source)
      @_undies_source_stack = SourceStack.new(source)
      raise ArgumentError, "please provide an Output object" if !output.kind_of?(Output)
      @_undies_output = output

      # apply data to template scope
      raise ArgumentError if !data.kind_of?(::Hash)
      if (data.keys.map(&:to_s) & self.public_methods.map(&:to_s)).size > 0
        raise ArgumentError, "data conflicts with template public methods."
      end
      metaclass = class << self; self; end
      data.each {|key, value| metaclass.class_eval { define_method(key){value} }}

      # yield to recursivley render the source stack
      self.__yield

      # flush any remaining output to the stream
      @_undies_output.flush
    end

    # call this to render template source
    # use this method in layouts to insert a layout's content source
    def __yield
      return if @_undies_source_stack.nil? || (source = @_undies_source_stack.pop).nil?
      if source.file?
        instance_eval(source.data, source.source, 1)
      else
        instance_eval(&source.data)
      end
    end

    # Add a text node (data escaped) to the nodes of the current node
    def _(data=""); self.__ self.escape_html(data.to_s); end

    # Add a text node with the data un-escaped
    def __(data=""); @_undies_output.node(data.to_s); end

    # Add an element to the nodes of the current node
    def element(*args, &block); @_undies_output.element(*args, &block); end
    alias_method :tag, :element

    # call this to render partial source embedded in a template
    # partial source is rendered with its own scope/data but shares
    # its parent template's output object
    def __partial(source, data)
      Undies::Template.new(source, data, @_undies_output)
    end

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
