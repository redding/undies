require 'undies/source'
require 'undies/node'
require 'undies/element'

module Undies
  class Template

    attr_accessor :nodes

    def initialize(file=nil, &block)
      @source = Source.new(file, block)
      @nodes = NodeList.new
      @stack = [self]
      if (@source).file?
        instance_eval(@source.data, @source.file, 1)
      else
        instance_eval(&@source.data)
      end
    end

    def to_s(pp_indent=nil)
      @nodes.join
    end

    # Add a text node (data escaped) to the nodes of the current node
    def _(data)
      @stack.last.nodes.append(Node.new(escape_html(data.to_s)))
    end

    # Add a text node with the data un-escaped
    def __(data)
      @stack.last.nodes.append(Node.new(data.to_s))
    end

    # add an element to the nodes of the current node
    def element(name, attrs={}, &block)
      @stack.last.nodes.append(Element.new(@stack, name, attrs, &block))
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

    private

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
