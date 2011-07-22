module Undies
  class Buffer < ::Array

    def initialize(*args)
      super()
    end

    # Add data and don't escape it
    def __(data="")
      append_item(data)
    end
    # Add data and escape it
    def _(data="")
      append_item(escape_html(data))
    end

    TAG_METH_REGEX = /^_(.+)$/

    def method_missing(meth, *args, &block)
      if meth.to_s =~ TAG_METH_REGEX
        tag($1, *args, &block)
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

    def tag(name, attrs={}, &block)
      append_item(new_tag=Tag.new(name, attrs, &block))
      new_tag
    end

    def to_s(pp_level=0, pp_indent=nil)
      self.collect do |i|
        begin
          i.to_s(pp_level, pp_indent)
        rescue ArgumentError => err
          pretty_print(i.to_s, pp_level, pp_indent)
        end
      end.join
    end

    protected

    def pretty_print(data, level, indent)
      if indent
        "#{' '*level*indent}#{data}\n"
      else
        data
      end
    end

    private

    def append_item(data)
      self << data
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