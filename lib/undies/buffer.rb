module Undies
  class Buffer < ::Array

    # Add data and don't escape it
    def __(data="")
      self << data
    end
    # Add data and escape it
    def _(data="")
      self << escape_html(data)
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
      self << Tag.new(name, attrs, &block)
      self.last
    end

    def to_s(pretty_print=false)
      # TODO: incorp pretty printing the HTML in the buffer
      self.collect do |i|
        begin
          i.to_s(pretty_print)
        rescue ArgumentError => err
          i.to_s
        end
      end.join
    end

    private

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