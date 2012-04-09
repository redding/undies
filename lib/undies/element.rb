module Undies



  module Element

    def self.hash_attrs(attrs="", ns=nil)
      return attrs.to_s if !attrs.kind_of?(::Hash)

      attrs.collect do |k_v|
        [ns ? "#{ns}_#{k_v.first}" : k_v.first.to_s, k_v.last]
      end.sort.collect do |k_v|
        if k_v.last.kind_of?(::Hash)
          hash_attrs(k_v.last, k_v.first)
        elsif k_v.last.kind_of?(::Array)
          " #{k_v.first}=\"#{escape_attr_value(k_v.last.join(' '))}\""
        else
          " #{k_v.first}=\"#{escape_attr_value(k_v.last)}\""
        end
      end.join
    end

    ESCAPE_ATTRS = {
      "&" => "&amp;",
      "<" => "&lt;",
      '"' => "&quot;"
    }
    ESCAPE_ATTRS_PATTERN = Regexp.union(*ESCAPE_ATTRS.keys)
    def self.escape_attr_value(value)
      value.to_s.gsub(ESCAPE_ATTRS_PATTERN){|c| ESCAPE_ATTRS[c] }
    end

    def self.open(*args, &build)
      Open.new(*args, &build)
    end

    def self.closed(*args, &build)
      Closed.new(*args, &build)
    end

  end



  module CSSProxy

    # CSS proxy methods ============================================
    ID_METH_REGEX = /^([^_].+)!$/
    CLASS_METH_REGEX = /^([^_].+)$/

    def method_missing(meth, *args, &block)
      if meth.to_s =~ ID_METH_REGEX
        @attrs[:id] = $1
        proxy(args, block)
      elsif meth.to_s =~ CLASS_METH_REGEX
        @attrs[:class] = [@attrs[:class], $1].compact.join(' ')
        proxy(args, block)
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
    # ==============================================================

  end



  module MergeAttrs

    def __attrs(attrs_hash=nil)
      return @attrs if attrs_hash.nil?
      @attrs.merge!(attrs_hash)
    end

  end



  class Raw < ::String

    # A Raw string is one that is impervious to String#gsub and returns itself
    # when `to_s` is called.

    def gsub(*args, &block)
      self
    end

    def gsub!(*args, &block)
      nil
    end

    def to_s
      self
    end

  end



  class Element::Open
    include CSSProxy
    include MergeAttrs

    def initialize(name, *args, &build)
      @name    = name.to_s
      @attrs   = {}
      @content = []
      @build   = nil

      proxy(args, build)
    end

    def __start_tag
      "<#{@name}#{Element.hash_attrs(@attrs)}>"
    end

    def __content
      @content.collect{ |c| Template.escape_html(c) }.join
    end

    def __build
      @build.call if @build
    end

    def __end_tag
      "</#{@name}>"
    end

    def to_s
      "#{__start_tag}#{__content}#{__end_tag}"
    end

    def ==(other)
      other.instance_variable_get("@name")    == @name    &&
      other.instance_variable_get("@attrs")   == @attrs   &&
      other.instance_variable_get("@content") == @content
    end

    # overriding this because the base Node class defines a 'to_s' method that
    # needs to be honored
    def to_str(*args)
      "Undies::Element::Open:#{self.object_id} " +
      "@name=#{@name.inspect}, @attrs=#{@attrs.inspect}, @content=#{@content.inspect}"
    end
    alias_method :inspect, :to_str

    private

    def proxy(args, build)
      if args.last.kind_of?(Hash)
        @attrs.merge!(args.pop)
      end

      @content.push *args
      @build = build

      self
    end

  end



  class Element::Closed
    include CSSProxy
    include MergeAttrs

    def initialize(name, attrs={})
      @name    = name.to_s
      @attrs   = {}
      proxy([attrs])
    end

    def __start_tag
      "<#{@name}#{Element.hash_attrs(@attrs)} />"
    end

    # closed elements have no content
    def __content; ''; end

    # closed elements should have no build so do nothing
    def __build; end

    # closed elements have no end tag
    def __end_tag; ''; end

    def to_s
      "#{__start_tag}"
    end

    def ==(other)
      other.instance_variable_get("@name")  == @name  &&
      other.instance_variable_get("@attrs") == @attrs
    end

    # overriding this because the base Node class defines a 'to_s' method that
    # needs to be honored
    def to_str(*args)
      "Undies::Element::Closed:#{self.object_id} " +
      "@name=#{@name.inspect}, @attrs=#{@attrs.inspect}"
    end
    alias_method :inspect, :to_str

    private

    def proxy(args, build=nil)
      @attrs.merge!(args.last || {})
      self
    end

  end



end
