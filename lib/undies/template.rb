require 'undies/io'
require 'undies/source'
require 'undies/root_node'
require 'undies/api'

module Undies
  class Template

    include API

    # have as many methods on the class level as possible to keep from
    # polluting the public instance methods, the instance scope, and to
    # maximize the effectiveness of the Template#method_missing logic

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
      @_undies_io = if args.last.kind_of?(Undies::IO)
        args.pop
      else
        raise ArgumentError, "please provide an IO object"
      end

      # apply any given data to template scope as instance variables
      (args.last.kind_of?(::Hash) ? args.pop : {}).each do |k, v|
        self.instance_variable_set("@#{k}", v)
      end

      # setup a source stack with the given source
      source = args.last.kind_of?(Source) ? args.pop : Source.new(Proc.new {})
      @_undies_source_stack = SourceStack.new(source)

      # push a root node onto the IO
      @_undies_io.push!(RootNode.new(@_undies_io)) if @_undies_io.empty?

      # yield to recursivley render the source stack
      __yield

      # flush any elements that need to be built
      __flush
    end

  end
end
