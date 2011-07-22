require 'undies/buffer'

module Undies
  class Tag < Buffer

    attr_reader :attrs

    def initialize(name=nil, attrs={}, &block)
      super
      @name = name
      @attrs = attrs
      self.content = block
    end

    ID_METH_REGEX = /^([^_].+)!$/
    CLASS_METH_REGEX = /^([^_].+)$/

    def method_missing(meth, *args, &block)
      if meth.to_s =~ ID_METH_REGEX
        proxy_id_attr($1, *args, &block)
      elsif meth.to_s =~ CLASS_METH_REGEX
        proxy_class_attr($1, *args, &block)
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

    def to_s(pp_level=0, pp_indent=nil)
      out = ""
      if @content
        out << pretty_print("<#{@name}#{html_attrs(@attrs)}>", pp_level, pp_indent)
        out << super(pp_level+1, pp_indent)
        out << pretty_print("</#{@name}>", pp_level, pp_indent)
      else
        out << pretty_print("<#{@name}#{html_attrs(@attrs)} />", pp_level, pp_indent)
      end
      out
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

    private

    def proxy_id_attr(value, attrs={}, &block)
      @attrs.merge!(:id => value)
      @attrs.merge!(attrs)
      self.content = block
      self
    end

    def proxy_class_attr(value, attrs={}, &block)
      @attrs[:class] = [@attrs[:class], value].compact.join(' ')
      @attrs.merge!(attrs)
      self.content = block
      self
    end

    def content=(block)
      if block
        @content = block
        instance_eval(&@content)
      end
    end

  end
end