require 'undies/source'
require 'undies/buffer'
require "undies/utils"
require 'rack/utils'

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
    def __(html="")
      @buffer << html
    end

    # Buffer tag markup to the template buffer
    # the building block of all macros and html generation
    # this builds an html element with optional attrs/content
    def tag(name, attrs={})
      if block_given?
        @buffer << "<#{name}#{html_attrs(attrs)}>"
        yield
        @buffer << "</#{name}>"
      else
        @buffer << "<#{name}#{html_attrs(attrs)} />"
      end
    end

    protected

    def tag_attrs(selector='', options={})
      Utils.selector_opts(selector).merge(options)
    end

    def html_attrs(opts)
      raise ArgumentError unless opts.kind_of? ::Hash
      if opts.empty?
        ''
      else
        ' '+opts.
        sort {|a,b|  a[0].to_s <=> b[0].to_s}.
        collect {|k_v| "#{k_v[0]}=\"#{k_v[1]}\""}.
        join(' ').
        strip
      end
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
