require 'undies/source'
require 'undies/buffer'
require "undies/utils"

module Undies
  class Template

    attr_reader :buffer

    def initialize(file=nil, &block)
      @source = Source.new(file, block)
      @buffer = Buffer.new
    end

    TAG_METH_REGEX = /^_(.+)$/

    def method_missing(meth, *args, &block)
      if meth.to_s =~ TAG_METH_REGEX
        tag($1, tag_attrs(*args), &block)
      else
        super
      end
    end

    def respond_to?(*args)
      if args.first.to_s =~ TAG_METH_REGEX
        true
      else
        super
      end
    end

    def to_s(pretty_print=false)
      evaluate_source
      @buffer.to_s(pretty_print)
    end

    # Buffer raw data to the template buffer
    def raw(html="")
      @buffer << html
    end
    alias_method :__, :raw

    # Buffer tag markup to the template buffer
    # the building block of all macros and html generation
    # this builds an html element with optional attrs/content
    def tag(name, attrs={})
      if block_given?
        @buffer << "<#{name}#{Utils.html_attrs(attrs)}>"
        yield
        @buffer << "</#{name}>"
      else
        @buffer << "<#{name}#{Utils.html_attrs(attrs)} />"
      end
    end

    protected

    def tag_attrs(selector='', options={})
      Utils.selector_opts(selector).merge(options)
    end

    def evaluate_source
      if @source.file?
        instance_eval(@source.data, @source.file, 1)
      else
        instance_eval(&@source.data)
      end
    end

  end
end
