# Undies
A pure-Ruby DSL for streaming templated HTML, XML, or plain text.  Named for its gratuitous use of the underscore.

## Installation

Add this line to your application's Gemfile:

    gem 'undies'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install undies

## Usage

```ruby
_ raw "<!DOCTYPE html>"
_html {
  _head {
    _title "Hello World"
  }
  body {
    _h1.main!.big "Hi There!"
    _p "this is a hello world & ", em("Undies"), " usage example."
  }
}
```

Will stream out

``` html
<!DOCTYPE html>
<html>
  <head>
    <title>Hello World</title>
  </head>
  <body>
    <h1 class="big" id="main">Hi There!</h1>
    <p>this is a hello world &amp; <em>Undies</em> usage example.</p>
  </body>
</html>
```

## Captured Output

### Plain text

All text is escaped by default.

```ruby
Undies::Template.escape_html("ab&<>'\"/yz")
# => "ab&amp;&lt;&gt;&#x27;&quot;&#x2F;yz"
```

Capture raw (un-escaped) text using the `raw` method

```ruby
raw "this will <em>not</em> be escaped"
# => "this will <em>not</em> be escaped"
```

### XML

Capture an empty element:

```ruby
element(:thing) # => "<thing />"

# use `tag` as an alias to `element`
tag('ns:thing') # => "<ns:thing />"
```

Capture an element with content:

```ruby
# basic content

element(:thing, "some content")
# => "<thing>some content</thing>"

# all content is escaped by default
element(:thing, "&<>")
# => "<thing>&amp;&lt;&gt;</thing>"

# you can force raw content using the `raw` method
element(:thing, raw("<raw>text</raw>"))
# => "<thing><raw>text</raw></thing>"

# you can pass in as many pieces of content as you like
element(:thing, "1 < 2", raw("<raw>text</raw>"), " & 4 > 3")
# => "<thing>1 &lt; 2<raw>text</raw>&amp; 4 &gt; 3</thing>"
```

Capture an element with attributes:

```ruby
element(:thing, "some content", :one => 1, 'a' => "Aye")
# => "<thing one=\"1\" a=\"Aye\">some content</thing>"
```

Capture nested elements:

```ruby
element(
  :thing,
  element('Something', "Some Content"),
  element('AnotherThing', "more content")
) # => "<thing><Something>Some Content</Something><AnotherThing>more content</AnotherThing></thing>"
```

### HTML

In general, all the same stuff applies.  However, you can call specific methods for all non-deprecated elements from the HTML 4.0.1 spec.

```ruby
br
# => "<br />"

span "something"
# => "<span>something</span>"

div "something", :style => "color: red"
# => "<div style=\"color: red\">somthing</div"

html(
  head(title("Hello World")),
  body(h1("Hi There!"))
) # => "<html><head><title>Hello World</title></head><body<h1>Hi There!</h1></body></html>"
```

You can't specify content blocks when capturing element output.  Any content blocks will be ignored.

```ruby
div("contents") {
  span "more content"
}
# => "<div>contents</div>"
```

Use bang (!) method calls to set id attributes

```ruby
h1.header!
# => "<h1 id=\"header\" />"

h1.header!.title!
# => "<h1 id=\"title\" />"
```

Use general method calls to add class attributes

```ruby
_h1.header.awesome
# => "<h1 class=\"header awesome\" />"
```

Use both in combination

```ruby
h1.header!.awesome
# => "<h1 class=\"awesome\" id=\"header\" />
```

## Streamed Output

Up to this point we've just looked at 'capture methods' - the generated output is just returned as a string.  Undies, however, is designed to stream generated content to a given IO.  This has a number of advantages:

* content is written out immediately
* maintain a relatively low memory profile while rendering
* can process large templates with linear performance impact

### Plain text

Stream plain text
*note*: this is only valid at the root of the view.  to add plain text to an element, pass it in as an argument.  it will get streamed out as the element is streamed.

```ruby
_ "this will be escaped"

_ raw("this will not be escaped")
```

### XML

Stream xml element markup.  Call the element and tag methods with two leading underscores.

```ruby
__element(:thing)

__tag('ns:thing')
```

All other element handling is the same.

### HTML

Stream html markup.  Call the html element methods with a leading underscore.

```ruby
_br

_span "something"

_div "something", :style => "color: red"

_html {
  _head { _title "Hello World" }
  _body {
    _h1 "Hi There!"
  }
}
```

All other element handling is the same.

### Notes on streamed output

* because content is streamed then forgotten as it is being rendered, streamed elements cannot be self-referrential.  No one element may refer to other previously rendered elements.
* streamed output will honor pretty printing settings - captured output is never pretty printed
* elements specified with content are printed on a single line
* elements specified with nested elements are always printed on multiple lines
* in general, define markup using streaming method calls for the main markup and add inline elements to content using the capture methods
* captured element output is always handled as raw markup and won't be escaped

## Rendering

To render using Undies, create a Template instance, providing the template source, data, and io information.

```ruby
source = Undies::Source.new("/path/to/sourcefile")
data   = { :two_plus_two => 4 }
io     = Undies::IO.new(@some_io_stream)

Undies::Template.new(source, data, io)
```

### Source

You specify Undies source using the Undies::Source object.  You can create source either form a block or a file.  Source content (either block or file) will be evaluated in context of the template.

### Data

Undies renders source content in the isolated scope of the Template.  This means that content has access to only the data it is given or the Undies API itself.  When you define a template for rendering, you provide not only the template source, but any data that source should be rendered with.  Data is given in the form of a Hash.  The string form of the hash keys are exposed as local instance variables assigned their corresponding values.

### IO

As said before, Undies streams to a given io stream.  You specify a Template's io by creating an Undies::IO object.  These objects take a stream and a hash of options:

* :pp (pretty-print) : set to a Fixnum to space-indent pretty print the streamed output.
* :level : the starting level to render pretty printed output at, default is zero

### Examples

file source, no local data, no pretty printing

```ruby
source = Undies::Source.new("/path/to/source")
Undies::Template.new(source, {}, Undies::IO.new(@io))
```

proc source, simple local data, no pretty printing

```ruby
source = Undies::Source.new(Proc.new do
  _div {
    _ @content.to_s
  }
end)
Undies::Template.new(source, {:content => "Some Content!!" }, Undies::IO.new(@io))
```

pretty printing (4 space tab indentation)

```ruby
source = Undies::Source.new("/path/to/source")
Undies::Template.new(source, {}, Undies::IO.new(@io, :pp => 4))
```

### Builder approach

The above examples use the "source rendering" approach.  This works great when you know your source content before render time and create a source object from it (ie rendering a view template).  However, in some cases, you may not know the source until render time and/or want to use a more declarative style to specify render output.  Undies content can be specified programmatically using the "builder rendering" approach.

To render using this approach, create a Template instance passing it data and io info as above.  However, don't pass in any source info, only pass in any local data if you like, and save off the created template:

```ruby
# choosing not to use any local data in this example
template = Undies::Template.new(Undies::IO.new(@io))
```

Now just interact with the Undies API directly.

```ruby
# notice that it becomes less important to bind any local data to the Template using this approach
something = "Some Thing!"
template._div.something! template._ something.to_s

template._div {
  template._span "hi"
}
```

*Note:* there is one extra caveat to be aware of using this approach.  You need to be sure and flush the template when content processing is complete.  Just pass the template to the Undies::Template#flush method:

```ruby
# ensures all content is streamed to the template's io stream
# this is necessary when not using the source approach above
Undies::Template.flush(template)
```

### Manual approach

There is another method you can use to render output: the manual approach.  Like the builder approach, this method is ideal when you don't know the source until render time.  The key difference is that blocks are not used to imply nesting relationships.  Using this approach, you manually 'push' and 'pop' to move up and down nesting relationship contexts.  So a push on an element would move the template context to the element pushed.  A pop would move back to the current context's parent element.  As you would expect, pop'ing on the root of a template has no effect on the context and pushing a non-element node has no effect on the context.

To render using this approach, create a Template as you would with the Builder approach.  Interact with the Undies API directly.  Use the Template#__push and Template#__pop methods to change the template scope.

```ruby
# this is the equivalent to the Builder approach example above

template = Undies::Template.new(Undies::IO.new(@io))

something = "Some Thing!"
template._div.something! something.to_s

template._div
template.__push
template._span "hi"
template.__pop

# alternate method for flushing a template
template.__flush
```

*Note:* as with the Builder approach, you must flush the template when content processing is complete.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
