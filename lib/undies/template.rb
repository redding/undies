require 'undies/source'
require 'undies/node'
require 'undies/element'

module Undies
  class Template

    attr_accessor :nodes

    def initialize(*args, &block)
      self.nodes = NodeList.new
      self.___stack = [self]
      self.___locals, source = self.___template_args(args, block)

      if (source).file?
        instance_eval(source.data, source.source, 1)
      else
        instance_eval(&source.data)
      end
    end

    def to_s(pp_indent=nil)
      self.nodes.collect{|n| n.to_s(0, pp_indent)}.join
    end

    # Add a text node (data escaped) to the nodes of the current node
    def _(data)
      self.___stack.last.nodes.append(Node.new(self.escape_html(data.to_s)))
    end

    # Add a text node with the data un-escaped
    def __(data)
      self.___stack.last.nodes.append(Node.new(data.to_s))
    end

    # Add an element to the nodes of the current node
    def element(name, attrs={}, &block)
      self.___stack.last.nodes.append(Element.new(self.___stack, name, attrs, &block))
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

    # prefixing non-public methods with a triple underscore to not pollute
    # metaclass locals scope

    def ___locals=(data)
      if !data.kind_of?(::Hash)
        raise ArgumentError
      end
      if invalid_locals?(data.keys)
        raise ArgumentError, "locals conflict with template's public methods."
      end
      data.each do |key, value|
        self.___metaclass do
          define_method(key) { value }
        end
      end
    end

    def ___stack=(value)
      raise ArgumentError if !value.respond_to?(:push) || !value.respond_to?(:pop)
      @stack = value
    end

    def ___stack
      @stack
    end

    def ___template_args(args, block)
      [ args.last.kind_of?(::Hash) ? args.pop : {},
        Source.new(block || args.first.to_s)
      ]
    end

    def ___metaclass(&block)
      metaclass = class << self; self; end
      metaclass.class_eval(&block)
    end

    private

    # you can't define locals that conflict with the template's public methods
    def invalid_locals?(keys)
      (keys.collect(&:to_s) & self.public_methods.collect(&:to_s)).size > 0
    end

  end
end
