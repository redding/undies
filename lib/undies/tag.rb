require 'undies/buffer'

module Undies
  class Tag < Buffer

    def initialize(name=nil, attrs={}, &block)
      super()
      @name = name
      @attrs = attrs
      @block = block
    end

    ID_METH_REGEX = /^[^_](.+)!$/
    CLASS_METH_REGEX = /^[^_](.+)$/

    def method_missing(meth, *args, &block)
      if meth.to_s =~ ID_METH_REGEX
        ""#id_attr($1, *args, &block)
      elsif meth.to_s =~ CLASS_METH_REGEX
        ""#class_attr($1, *args, &block)
      else
        super
      end
    end

    def respond_to?(*args)
      if args.first.to_s =~ ID_METH_REGEX || args.first.to_s =~ CLASS_METH_REGEX
        true
      else
        super
      end
    end

    def to_s(pretty_print=false)
      if @block
        self << "<#{@name}#{html_attrs(@attrs)}>"
        instance_eval(&@block)
        self << "</#{@name}>"
      else
        self << "<#{@name}#{html_attrs(@attrs)} />"
      end
      super(pretty_print)
    end

    protected

    def html_attrs(attrs={})
      raise ArgumentError unless attrs.kind_of? ::Hash
      if attrs.empty?
        ''
      else
        ' '+attrs.
        sort {|a,b|  a[0].to_s <=> b[0].to_s}.
        collect {|k_v| "#{k_v[0]}=\"#{k_v[1]}\""}.
        join(' ').
        strip
      end
    end

  end
end