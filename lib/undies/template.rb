require 'undies/source'
require 'undies/node'
require 'undies/element'

module Undies
  class Template

    attr_accessor :nodes

    def initialize(*args, &block)
      @nodes = NodeList.new
      @stack = [self]
      self.data, @source = source_data(args, block)

      if (@source).file?
        instance_eval(@source.data, @source.file, 1)
      else
        instance_eval(&@source.data)
      end
    end

    def to_s(pp_indent=nil)
      @nodes.collect{|n| n.to_s(0, pp_indent)}.join
    end

    # Add a text node (data escaped) to the nodes of the current node
    def _(data)
      @stack.last.nodes.append(Node.new(escape_html(data.to_s)))
    end

    # Add a text node with the data un-escaped
    def __(data)
      @stack.last.nodes.append(Node.new(data.to_s))
    end

    # Add an element to the nodes of the current node
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

    protected

    def data=(data)
      raise ArgumentError if !data.kind_of?(::Hash)
      data.each do |key, value|
        metaclass do
          define_method(key) { value }
        end
      end
    end

    def source
      @source
    end

    def stack
      @stack
    end

    private

    def source_data(args, block)
      [ args.last.kind_of?(::Hash) ? args.pop : {},
        Source.new(args.first.to_s, block)
      ]
    end

    def metaclass(&block)
      metaclass = class << self; self; end
      metaclass.class_eval(&block)
    end

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
