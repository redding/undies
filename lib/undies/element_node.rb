module Undies
  class ElementNode

    # TODO: optimize this
    def self.hash_attrs(attrs="", ns=nil)
      return attrs.to_s if !attrs.kind_of?(::Hash)

      attrs.collect do |k_v|
        [ns ? "#{ns}_#{k_v.first}" : k_v.first.to_s, k_v.last]
      end.sort.inject('') do |html, k_v|
        html << if k_v.last.kind_of?(::Hash)
          hash_attrs(k_v.last, k_v.first)
        else
          " #{k_v.first}=\"#{escape_attr_value(k_v.last)}\""
        end
      end
    end

    # TODO: can optimize this any?
    def self.escape_attr_value(value)
      value.
        to_s.
        gsub('&', '&amp;').
        gsub('<', '&lt;').
        gsub('"', '&quot;')
    end

    def initialize(io, name, attrs={}, &build)
      @start_tag_written = false
      @end_tag_line_indent = false
      @has_content = false
      @cached = nil

      @io = io
      @name  = name.to_s
      @attrs = attrs
      add_build(build) if build
    end

    def __cached; @cached; end
    def __build; @build; end
    def __attrs(attrs_hash=nil)
      return @attrs if attrs_hash.nil?
      @attrs.merge!(attrs_hash)
    end

    def to_s
      @io.push(self)

      @build.call if @build
      __flush
      @io.pop
      write_end_tag

      # needed so the `write_cached` calls on Element and Node won't add
      # anything else to the IO
      return ""
    end

    def __push
      @has_content ||= true
      @io.push(@cached)
      @cached = nil
    end

    def __pop
      @has_content ||= true
      __flush
      @io.pop
      write_end_tag
    end

    def __flush
      write_cached
      @cached = nil
      self
    end

    # TODO: this is deprecated and will be removed when capturing is in place
    def __markup(raw)
      @has_content ||= true
      if !@start_tag_written
        # no newline
        # -1 level offset b/c we are operating on the element build one deep
        write_start_tag('', -1)
        # write_cached
        @cached = raw.to_s
      else
        write_cached
        @cached = "#{@io.line_indent}#{raw}#{@io.newline}"
        @end_tag_line_indent ||= true
      end
    end

    def __element(element)
      @has_content ||= true
      if !@start_tag_written
        # with newline
        # -1 level offset b/c we are operating on the element build one deep
        write_start_tag(@io.newline, -1)
      end
      @end_tag_line_indent ||= true
      write_cached
      @cached = element
    end

    def __partial(partial)
      __element(partial)
    end

    # CSS proxy methods ============================================
    ID_METH_REGEX = /^([^_].+)!$/
    CLASS_METH_REGEX = /^([^_].+)$/

    def method_missing(meth, *args, &block)
      if meth.to_s =~ ID_METH_REGEX
        proxy($1, args.first || {}, block) do |value|
          @attrs.merge!(:id => value)
        end
      elsif meth.to_s =~ CLASS_METH_REGEX
        proxy($1, args.first || {}, block) do |value|
          @attrs[:class] = [@attrs[:class], value].compact.join(' ')
        end
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

    def ==(other)
      other.instance_variable_get("@name")  == @name  &&
      other.instance_variable_get("@attrs") == @attrs
    end

    # overriding this because the base Node class defines a 'to_s' method that
    # needs to be honored
    def to_str(*args)
      "Undies::ElementNode:#{self.object_id} " +
      "@name=#{@name.inspect}, @attrs=#{@attrs.inspect}"
    end
    alias_method :inspect, :to_str

    private

    # private methods are needed so as not to pollute the
    # method_missing public scope

    def proxy(value, attrs, build)
      yield value if block_given?
      @attrs.merge!(attrs)
      add_build(build) if build
      self
    end

    def write_cached
      @io << @cached.to_s
    end

    def write_start_tag(newline='', level_offset=0)
      @io << "#{@io.line_indent(level_offset)}#{start_tag}#{newline}"
      @start_tag_written = true
    end

    def write_end_tag(level_offset=0)
      if !@start_tag_written
        write_start_tag('', level_offset)
      elsif @end_tag_line_indent
        @io << @io.line_indent(level_offset)
      end
      @io << end_tag
    end

    def start_tag
      "<#{@name}#{self.class.hash_attrs(@attrs)}#{@has_content ? '>' : ' />'}"
    end

    def end_tag
      @has_content ? "</#{@name}>#{@io.newline}" : @io.newline
    end

    # only keep the latest build added
    def add_build(build)
      @build = build
      @has_content ||= true
    end

  end
end
