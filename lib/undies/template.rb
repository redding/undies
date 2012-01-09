require 'undies/source_stack'
require 'undies/output'
require 'undies/node'
require 'undies/element'


module Undies
  class Template

    # have as many methods on the class level as possible to keep from
    # polluting the public instance methods, the instance scope, and to
    # maximize the effectiveness of the Template#method_missing logic

    def self.output(template)
      template.instance_variable_get("@_undies_output")
    end

    def self.flush(template)
      template.instance_variable_get("@_undies_output").flush
    end

    def initialize(*args)
      output = if args.last.kind_of?(Output)
        args.pop
      else
        raise ArgumentError, "please provide an Output object"
      end
      data = args.last.kind_of?(::Hash) ? args.pop : {}
      source = args.last.kind_of?(Source) ? args.pop : Source.new(Proc.new {})

      # setup the source stack and output objects
      @_undies_source_stack = SourceStack.new(source)

      # apply data to template scope
      if (data.keys.map(&:to_s) & self.public_methods.map(&:to_s)).size > 0
        raise ArgumentError, "data conflicts with template public methods."
      end
      metaclass = class << self; self; end
      data.each {|key, value| metaclass.class_eval { define_method(key){value} }}

      # save off the output obj for streaming
      @_undies_output = output

      # yield to recursivley render the source stack
      self.__yield

      # flush any remaining output to the stream
      self.class.flush(self)
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

    # call this to render partial source embedded in a template
    # partial source is rendered with its own scope/data but shares
    # its parent template's output object
    def __partial(source, data)
      Undies::Template.new(source, data, @_undies_output)
    end

    # Add a text node (data escaped) to the nodes of the current node
    def _(data=""); self.__ self.escape_html(data.to_s); end

    # Add a text node with the data un-escaped
    def __(data=""); @_undies_output.node(Node.new(data.to_s)); end

    # Add an element to the nodes of the current node
    def element(*args, &block); @_undies_output.node(Element.new(*args, &block)); end
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
