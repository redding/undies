require 'undies/source_stack'
require 'undies/node_stack'
require 'undies/output'

require 'undies/node'
require 'undies/element'

module Undies
  class Template

    # have as many methods on the class level as possible to keep from
    # polluting the public instance methods, the instance scope, and to
    # maximize the effectiveness of the Template#method_missing logic

    def __source_stack
      @_undies_source_stack
    end

    def __node_stack
      @_undies_node_stack
    end

    def self.flush(template)
      template.__flush
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
    def self.escape_html(string)
      string.to_s.gsub(ESCAPE_HTML_PATTERN){|c| ESCAPE_HTML[c] }
    end
    # end Rip from Rack v1.3.0 =====================================

    def initialize(*args)
      # setup a node stack with the given output obj
      output = if args.last.kind_of?(NodeStack) || args.last.kind_of?(Output)
        args.pop
      else
        raise ArgumentError, "please provide an Output object"
      end
      @_undies_node_stack = NodeStack.create(output)

      # apply any given data to template scope
      data = args.last.kind_of?(::Hash) ? args.pop : {}
      if (data.keys.map(&:to_s) & self.public_methods.map(&:to_s)).size > 0
        raise ArgumentError, "data conflicts with template public methods."
      end
      metaclass = class << self; self; end
      data.each {|key, value| metaclass.class_eval { define_method(key){value} }}

      # setup a source stack with the given source
      source = args.last.kind_of?(Source) ? args.pop : Source.new(Proc.new {})
      @_undies_source_stack = SourceStack.new(source)

      # yield to recursivley render the source stack
      self.__yield

      # flush any elements that need to be built
      self.__flush
    end

    # call this to modify element attrs inside a build block.  Once content
    # or child elements have been added, any '__attr' directives will
    # be ignored b/c the elements start_tag has already been flushed
    # to the output
    def __attrs(attrs_hash={})
      self.__node_stack.current.tap do |node|
        if node
          node.__merge_attrs(attrs_hash)
          node.__set_start_tag
        end
      end
    end

    # call this method to manually push the currently cached node onto the
    # node stack
    # - implicitly flushes the cache
    # - changes the context of template method calls to operate on that node
    def __push
      ns = self.__node_stack
      node, ns.cached_node = ns.cached_node, nil
      if node
        # add an empty build block to generate a non-closing start tag
        # and a closing end tag
        node.__add_build(Proc.new {})
        node.__set_start_tag
        node.__set_end_tag

        ns.push(node)
      end
    end

    # call this method to manually pop the current scoped node from the node stack
    # - flushes the cache
    # - changes the context of template method calls to operate on the parent node
    def __pop
      ns = self.__node_stack
      ns.clear_cached
      ns.pop
    end

    # call this to manually flush a template
    def __flush
      self.__node_stack.flush
    end

    # call this to render template source
    # use this method in layouts to insert a layout's content source
    def __yield
      return if self.__node_stack.nil? || (source = self.__source_stack.pop).nil?
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
        Undies::Template.new(source, data, self.__node_stack)
      else
        self.__ source.to_s, :partial
      end
    end

    # Add a text node (data escaped) to the nodes of the current node
    def _(data="", mode=:inline)
      self.__ self.class.escape_html(data.to_s), mode
    end

    # Add a text node with the data un-escaped
    def __(data="", mode=:inline)
      Node.new(data.to_s, mode).tap do |node|
        self.__node_stack.node(node)
      end
    end

    # Add an element to the node stack
    def element(*args, &build)
      Element.new(*args, &build).tap do |element|
        self.__node_stack.node(element)
      end
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

  end
end
