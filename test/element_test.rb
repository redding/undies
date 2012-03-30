require "assert"
require 'undies/io'
require "undies/element"


class Undies::Element

  class BasicTests < Assert::Context
    desc 'an element'
    before do
      # io test with :pp 1 so we can test newline insertion
      # io test with level 1 so we can test element start tag writing
      @io = Undies::IO.new(@out = "", :pp => 1, :level => 1)
      @e = Undies::Element.new(@io, :div)
    end
    subject { @e }

    should have_class_methods :hash_attrs, :escape_attr_value
    should have_instance_methods :__attrs, :__flush, :__push, :__pop
    should have_instance_methods :__markup, :__element, :__partial
    should have_instance_methods :__cached, :__builds

    should "know its name and store it as a string" do
      assert_equal "div", subject.instance_variable_get("@name")
    end

    should "have no builds by default" do
      assert_empty subject.__builds
    end

    should "have nothing cached by default" do
      assert_nil subject.__cached
    end

  end



  class HashAttrsTest < BasicTests
    desc "the element class hash_attrs util"

    should "convert an empty hash to element attrs" do
      assert_equal '', Undies::Element.hash_attrs({})
    end

    should "convert a basic hash to element attrs" do
      attrs = Undies::Element.hash_attrs(:class => "test", :id => "test_1")
      assert_match /^\s{1}/, attrs
      assert_includes 'class="test"', attrs
      assert_includes 'id="test_1"', attrs

      attrs = Undies::Element.hash_attrs('key' => "string")
      assert_includes 'key="string"', attrs
    end

    should "escape double-quotes in attr values" do
      attrs = Undies::Element.hash_attrs('escaped' => '"this" is double-quoted')
      assert_includes 'escaped="&quot;this&quot; is double-quoted"', attrs
    end

    should "escape '<' in attr values" do
      attrs = Undies::Element.hash_attrs('escaped' => 'not < escaped')
      assert_includes 'escaped="not &lt; escaped"', attrs
    end

    should "escape '&' in attr values" do
      attrs = Undies::Element.hash_attrs('escaped' => 'not & escaped')
      assert_includes 'escaped="not &amp; escaped"', attrs
    end

    should "convert a nested hash to element attrs" do
      attrs = Undies::Element.hash_attrs({
        :class => "testing", :id => "test_2",
        :nested => {:something => 'is_awesome'}
      })
      assert_match /^\s{1}/, attrs
      assert_included 'class="testing"', attrs
      assert_included 'id="test_2"', attrs
      assert_included 'nested_something="is_awesome"', attrs
    end
  end



  class CSSProxyTests < BasicTests

    should "respond to any method ending in '!' as an id proxy" do
      assert subject.respond_to?(:asdgasdg!)
    end

    should "proxy id attr with methods ending in '!'" do
      assert_equal({
        :id => 'thing1'
      }, subject.thing1!.__attrs)
    end

    should "proxy id attr with last method call ending in '!'" do
      assert_equal({
        :id => 'thing2'
      }, subject.thing1!.thing2!.__attrs)
    end

    should "set id attr to explicit if called last " do
      assert_equal({
        :id => 'thing3'
      }, subject.thing1!.thing2!(:id => 'thing3').__attrs)
    end

    should "set id attr to proxy if called last" do
      assert_equal({
        :id => 'thing1'
      }, subject.thing2!(:id => 'thing3').thing1!.__attrs)
    end

    should "respond to any other method as a class proxy" do
      assert_respond_to :asdgasdg, subject
    end

    should "proxy single html class attr" do
      assert_equal({
        :class => 'thing'
      }, subject.thing.__attrs)
    end

    should "proxy multi html class attrs" do
      assert_equal({
        :class => 'list thing awesome'
      }, subject.list.thing.awesome.__attrs)
    end

    should "set class attr with explicit if called last " do
      assert_equal({
        :class => 'list'
      }, subject.thing.awesome(:class => "list").__attrs)
    end

    should "update class attr with proxy if called last" do
      assert_equal({
        :class => 'list is good'
      }, subject.thing.awesome(:class => "list is").good.__attrs)
    end

    should "proxy mixed class and id selector attrs" do
      subject.thing1!.awesome({:class => "list is", :id => "thing2"}).good.thing3!

      assert_equal({
        :class => 'list is good',
        :id => "thing3"
      }, subject.__attrs)
    end

  end



  class AddContentTests < BasicTests
    desc "adding content"
    before do
      @raw1  = "some raw markup"
      @raw2  = "more raw markup"
      @elem1 = Undies::Element.new(@io, :strong) {}
      @elem2 = Undies::Element.new(@io, :br)

      # make the subject element have a build since we are simulating build
      # markup operations
      @e = Undies::Element.new(@io, :div) {}
    end

  end

  class AddContentStartTagWrittenTests < AddContentTests
    desc "(the start tag has already been written)"
    before do
      subject.instance_variable_set("@start_tag_written", true)
    end

  end

  class AddContentStartTagNotWrittenTests < AddContentTests
    desc "(the start tag has not been written)"
    before do
      subject.instance_variable_set("@start_tag_written", false)
    end

  end

  class MarkupStartTagWrittenTests < AddContentStartTagWrittenTests
    desc "using the __markup meth"

    should "cache any raw markup given with line indent and newline" do
      subject.__markup @raw1
      assert_equal "#{@io.line_indent}#{@raw1}#{@io.newline}", subject.__cached
    end

    should "write out any cached value when new markup is given" do
      subject.__markup @raw1
      assert_empty @out

      subject.__markup @raw2
      assert_equal "#{@io.line_indent}#{@raw1}#{@io.newline}", @out
    end

    should "write out any cached value when flushed" do
      subject.__flush
      assert_empty @out

      subject.__markup @raw1
      subject.__flush
      assert_equal "#{@io.line_indent}#{@raw1}#{@io.newline}", @out
    end

  end

  class MarkupStartTagNotWrittenTests < AddContentStartTagNotWrittenTests
    desc "using the __markup meth"

    should "cache any raw markup given without line indent or newline" do
      subject.__markup @raw1
      assert_equal @raw1.to_s, subject.__cached
    end

    should "write out the start tag with no IO#newline when markup is given" do
      subject.__markup @raw1
      assert_equal "<div>", @out
    end

    should "write out any cached content and cache new markup when given" do
      subject.__markup @raw1
      subject.__markup @raw2
      assert_equal "<div>#{@raw1}", @out
      assert_equal "#{@io.line_indent}#{@raw2}#{@io.newline}", subject.__cached
    end

  end

  class ElementStartTagWrittenTests < AddContentStartTagWrittenTests
    desc "using the __element meth"

    should "cache any element given" do
      subject.__element(@elem1)
      assert_equal @elem1, subject.__cached
    end

    should "return the element" do
      assert_equal @elem1, subject.__element(@elem1)
    end

    should "write out any cached value when a new element is given" do
      subject.__element(@elem1)
      assert_empty @out

      subject.__element(@elem2)
      assert_equal "#{@io.line_indent}<strong></strong>#{@io.newline}", @out
    end

    should "write out any cached value when flushed" do
      subject.__flush
      assert_empty @out

      subject.__element(@elem1)
      subject.__flush
      assert_equal "#{@io.line_indent}<strong></strong>#{@io.newline}", @out
    end

  end

  class ElementStartTagNotWrittenTests < AddContentStartTagNotWrittenTests
    desc "using the __element meth"

    should "cache any element given" do
      subject.__element(@elem1)
      assert_equal @elem1, subject.__cached
    end

    should "return the element" do
      assert_equal @elem1, subject.__element(@elem1)
    end

    should "write out the start tag with IO#newline when an element is given" do
      subject.__element(@elem1)
      assert_equal "<div>#{@io.newline}", @out
    end

    should "write out any cached content and cache new markup when given" do
      subject.__element @elem1
      subject.__element @elem2
      assert_equal "<div>#{@io.newline}#{@io.line_indent}<strong></strong>#{@io.newline}", @out
      assert_equal @elem2, subject.__cached
    end

    should "write out the end tag with IO#newline indented when a partial is given" do
      subject.__element(@elem1)
      subject.__pop
      assert_equal "<div>#{@io.newline} <strong></strong>#{@io.newline}</div>#{@io.newline}", @out
    end

  end

  class PartialStartTagWrittenTests < AddContentStartTagWrittenTests
    desc "using the __partial meth"

    should "cache any partial markup given" do
      subject.__partial("partial markup")
      assert_equal "partial markup", subject.__cached
    end

    should "write out any cached partial values" do
      subject.__partial("partial markup")
      assert_empty @out

      subject.__element(@elem2)
      assert_equal "partial markup", @out
    end

    should "write out any cached value when flushed" do
      subject.__flush
      assert_empty @out

      subject.__partial("partial markup")
      subject.__flush
      assert_equal "partial markup", @out
    end

  end

  class PartialStartTagNotWrittenTests < AddContentStartTagNotWrittenTests
    desc "using the __partial meth"

    should "cache any element given" do
      subject.__partial("partial markup")
      assert_equal "partial markup", subject.__cached
    end

    should "write out the start tag with IO#newline when a partial is given" do
      subject.__partial("partial markup")
      assert_equal "<div>#{@io.newline}", @out
    end

    should "write out the end tag with IO#newline indented when a partial is given" do
      subject.__partial("  partial markup\n")
      subject.__pop
      assert_equal "<div>#{@io.newline}  partial markup\n</div>#{@io.newline}", @out
    end

  end

  class AttrsTests < AddContentStartTagNotWrittenTests
    desc "using the __attrs meth"

    should "modify the parent element's tag attributes" do
      subject.__attrs(:test => 'value')
      subject.__markup "blah"

      assert_equal "<div test=\"value\">", @out
    end

    should "not effect the start tag once markup has been written" do
      subject.__attrs(:test => 'value')
      subject.__markup "blah"
      subject.__attrs(:another => 'val')

      assert_equal "<div test=\"value\">", @out
    end

    should "not effect the start tag once chile elements have been written" do
      subject.__attrs(:test => 'value')
      subject.__element(@elem1)
      subject.__attrs(:another => 'val')

      assert_equal "<div test=\"value\">#{@io.newline}", @out
    end

  end



  class SerializeTests < BasicTests

    should "serialize with no child elements" do
      Undies::Element.new(@io, :br).to_s
      assert_equal "#{@io.line_indent}<br />#{@io.newline}", @out
    end

    should "serialize with attrs" do
      Undies::Element.new(@io, :br, :class => 'big').to_s
      assert_equal "#{@io.line_indent}<br class=\"big\" />#{@io.newline}", @out
    end

    should "serialize with attrs that have double-quotes" do
      Undies::Element.new(@io, :br, :class => '"this" is double-quoted').to_s
      assert_equal "#{@io.line_indent}<br class=\"&quot;this&quot; is double-quoted\" />#{@io.newline}", @out
    end

    should "serialize with empty content" do
      (Undies::Element.new(@io, :strong) {}).to_s
      assert_equal "#{@io.line_indent}<strong></strong>#{@io.newline}", @out
    end

    should "serialize with attrs and content" do
      # content added using manual build
      elem = Undies::Element.new(@io, :strong, {:class => 'big'})
      elem.__push
      elem.__markup "Loud Noises!"
      elem.__pop

      assert_equal "#{@io.line_indent}<strong class=\"big\">Loud Noises!</strong>#{@io.newline}", @out
    end

    should "serialize element proxy id call" do
      # content added using build block
      elem = Undies::Element.new(@io, :div).thing1!
      elem.send("add_build", Proc.new do
        elem.__markup "stuff"
      end)
      elem.to_s

      assert_equal "#{@io.line_indent}<div id=\"thing1\">stuff</div>#{@io.newline}", @out
    end

    should "serialize element proxy class call" do
      # calling a private method as public to test private methods not
      # polluting public method_missing scope
      elem = Undies::Element.new(@io, :div).end_tag
      elem.send("add_build", Proc.new do
        elem.__markup "stuff"
      end)
      elem.to_s

      assert_equal "#{@io.line_indent}<div class=\"end_tag\">stuff</div>#{@io.newline}", @out
    end

    should "serialize content from separate content blocks" do
      elem = Undies::Element.new(@io, :div)
      elem.send("add_build", Proc.new do
        elem.__markup "stuff"
      end)
      elem.thing1!
      # will be serialized with a newline b/c its not the first markup content
      elem.send("add_build", Proc.new do
        elem.__markup "and more stuff"
        elem.__markup "and even more stuff"
      end)
      elem.to_s

      assert_equal "#{@io.line_indent}<div id=\"thing1\">stuff  and more stuff
  and even more stuff
 </div>
", @out
    end

    should "serialize nested elements with pp" do
      io = Undies::IO.new(@out = "", :pp => 1, :level => 0)

      elem_1a = Undies::Element.new(io, :span)
      elem_1a.send("add_build", Proc.new do
        elem_1a.__markup "Content!"
      end)

      elem_1b = Undies::Element.new(io, :span)
      elem_1b.send("add_build", Proc.new do
        elem_1b.__markup "More content"
      end)

      # test you can chain proxy calls and 'add_build' sends
      elem_1c = Undies::Element.new(io, :div)
      elem_1c.
        proxy.
        send("add_build", Proc.new do
          elem_1c.__markup "first build"
        end).
        start_tag.
        you!.
        send("add_build", Proc.new do
          elem_1c.__markup "second build"
          elem_1c.__markup "third build"
        end)


      elem_root = Undies::Element.new(io, :div)
      elem_root.send("add_build", Proc.new do
        elem_root.__element(elem_1a)
        elem_root.__markup "Raw"
        elem_root.__element(elem_1b)
        elem_root.__element(elem_1c)
      end).to_s

      assert_equal "<div>
 <span>Content!</span>
 Raw
 <span>More content</span>
 <div class=\"proxy start_tag\" id=\"you\">first build  second build
  third build
 </div>
</div>
", @out
    end

  end

end
