# Undies Models

## `IO`

Used internally to handle generated output streaming.  An instance of this class is required when defining Template objects.

```ruby
output = ""
templ  = Undies::Template.new(Undies::IO.new(output, :pp => 2))
```

Create IO objects by passing two arguments:

* *stream*: a stream for writing generated output to.  the only requirement is it must respond to `<<`.
* *options hash*: a hash of output options:
** `:pp`: (pretty print) indent size.  an integer specifying how many spaces each level of indent should be.  is `nil` by default and implies no pretty printed output
** `:pp_level`: the starting level for pretty printing.  is zero by default.

### API

#### Attributes

* `stream`: the io steam being written to
* `newline`: the newline character for this IO.  set to `"\n"` if `:pp` option is not nil, `""` otherwise
* `level`: the current pp level
* `indent`: the amount of spaces in each indent level
* `node_stack`: the stack of nodes being written on
* `current`: the current node being written (`node_stack.last`)

#### Methods

* `write`: write the given text to the io stream.  aliased as `<<`.
* `push`: given a node object, pushes it onto the node stack and increments the level
* `push!`: given a node object, pushes it onto the node stack - no level changes
* `pop`: pops the current node from the node stack and decrements the level
* `options=`: pass a hash to reset (no merge) the IO options


## `Template`

Build with an IO object to generate tempalated markup.  Can supply a data hash to render on.  Can either supply Source templates that are evaluated in the Template scope, or you can build the template object and drive using a more builder like render approach.  See the README for more details on building templates and rendering.

### API

#### Markup methods

* `_`:  pass a string to insert escaped markup or text
* `__`: pass a string to insert unescaped markup or text
* `_<element>`: any method prefixed with an '_' will define an element with that name.  Aliased as `tag` and `element`.
* `__attrs`: pass a Hash to modify parent element attributes within the build.  Merges with current attributes.
* `__yield`: render nested content (ie from a layout) when rendering using nested Source objects.
* `__partial`: insert markup generated with its own source/data/scope into the template.

#### Flow Control methods

* `__push`: used to change the template scope to modify on the latest child element.  Needed in manual render approach.
* `__pop`:  used to change the template scope back to modify on the parent element.
* `__flush`: used to flush any cached markup to the IO.  You must call this after rendering is complete if using the builder or manual render approaches.  Can call using the singleton Template variant: `Undies::Template.flush(my_template_obj)`


## `RootNode`

Used internally to implement the markup tree nodes.  Each node caches and processes nested markup and elements.  At each node level in the markup tree, nodes/markup are cached until the next sibling node or raw markup is defined, or until the node is flushed.  This keeps nodes from bloating memory on large documents and allows for output streaming.

### API

#### Attributes

* `__cached`: the currently cached markup/element
* `__builds`: the builds that should be run in the root scope

#### Methods

* `__attrs`: does nothing.  If called on the root of a document it has no effect.
* `__flush`: flush any cached markup to the IO
* `__markup`: pass raw markup.  will write any cached markup and cache this new markup.
* `__element`: pass an element node.  will write any cached markup and cache the new element.
* `__partial`: insert raw markup (just calls __markup, needed by Template API)
* `__push`: will clear and push the cached node/markup to the IO handler, changing the Template API scope to that node/markup.
* `__pop`: flush.  should have no effect on the IO handler if called.


## `Element`

Handles tag element markup and the scope for building and nesting markup.

### API

#### Singleton Methods

* `Element#hash_attrs`: given a nested hash, serialize to markup tag attribute string
* `Element#escape_attr_value`: given a value, escape it for attribute string use

#### Attributes

* `__cached`: the currently cached child markup/element
* `__builds`: any builds should be run against the Element

#### Methods

* `__attrs`: pass a hash.  merges given hash with element attrbutes.  only has an effect if called before the start tag is written (before any child elements or markup is defined).
* `__flush`: flush any cached markup to the IO
* `__markup`: pass raw markup.  will write any cached markup and cache this new markup.  writes the start tag appropriately if not already written.
* `__element`: pass an element node.  will write any cached markup and cache the new element.  writes the start tag appropriately if not already written.
* `__partial`: insert raw markup as child element markup (just calls __element, needed by Template API)
* `__push`: will clear and push the cached node/markup to the IO handler, changing the Template API scope to that node/markup.
* `__pop`: flushes any cached markup and will pop the current node/markup from the IO handler.  changes the Template API scope to that parent node/markup.  finally writes the end tag appropriately.
* `to_s`: pushes itself to the IO handler, changing the Template API scope to operate on itself.  calls any builds for the element.  calls `__pop` once builds have run.

## `Source`

TODO

## `SourceStack`

TODO
