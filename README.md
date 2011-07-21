# Undies
A pure-Ruby HTML templating DSL.  Named for its gratuitus use of the underscore.
## Installation
    gem install undies
## Usage
1. Empty tag:
    _br
    # => "<br />"
2. Tag with content:
    _h1 {
      _ "Some Header"
    } # => "<h1>Some Header</h1>"
3. Nested tags:
    _body {
      _div {
        _ "Some Content"
      }
    } # => "<body><div>Some Content</div></body>"
4. Buffer escaped output:
    _ "this will be escaped & and added to the buffer"
    # => "this will be escaped &amp; added to the buffer"
5. Buffer un-escaped output:
    __ "this will <em>not</em> be escaped"
    # => "this will <em>not</em> be escaped"
6. Tag with attributes
    _h1(:class => 'title', :title => "A Header")
    # => "<h1 class=\"title\" title=\"A Header\" />"
7. Tag with id attribute
    _h1.header!
    # => "<h1 id=\"header\" />"
8. Tag with class attributes
    _h1.header.awesome
    # => "<h1 class=\"header awesome\" />"

## License

Copyright (c) 2011 Kelly D. Redding

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
