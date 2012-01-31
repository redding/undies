require "assert"

require 'undies/node'
require "undies/output"
require "undies/template"

require "undies/element"


class Undies::Element

  class BasicTests < Assert::Context
    desc 'an element'
    before do
      @e = Undies::Element.new(:div)
    end
    subject { @e }

    should have_class_methods :hash_attrs, :set_children, :children, :prefix
    should have_instance_method :to_str

    should "be a Node" do
      assert_kind_of Undies::Node, subject
    end

    should "store it's name as a string" do
      assert_equal "div", subject.instance_variable_get("@name")
    end

    should "know it's start/end tags" do
      assert_equal "<div />", subject.class.start_tag(subject)
      assert_empty subject.class.end_tag(subject)
    end

    should "have no content itself" do
      assert_empty subject.class.content(subject)
    end

    should "have no builds by default" do
      assert_empty subject.class.builds(subject)
      assert_empty subject.class.builds(nil)
    end

    should "have no children by default" do
      assert_equal false, subject.class.children(subject)
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
      }, subject.thing1!.instance_variable_get("@attrs"))
    end

    should "proxy id attr with last method call ending in '!'" do
      assert_equal({
        :id => 'thing2'
      }, subject.thing1!.thing2!.instance_variable_get("@attrs"))
    end

    should "set id attr to explicit if called last " do
      assert_equal({
        :id => 'thing3'
      }, subject.thing1!.thing2!(:id => 'thing3').instance_variable_get("@attrs"))
    end

    should "set id attr to proxy if called last" do
      assert_equal({
        :id => 'thing1'
      }, subject.thing2!(:id => 'thing3').thing1!.instance_variable_get("@attrs"))
    end

    should "respond to any other method as a class proxy" do
      assert subject.respond_to?(:asdgasdg)
    end

    should "proxy single html class attr" do
      assert_equal({
        :class => 'thing'
      }, subject.thing.instance_variable_get("@attrs"))
    end

    should "proxy multi html class attrs" do
      assert_equal({
        :class => 'list thing awesome'
      }, subject.list.thing.awesome.instance_variable_get("@attrs"))
    end

    should "set class attr with explicit if called last " do
      assert_equal({
        :class => 'list'
      }, subject.thing.awesome(:class => "list").instance_variable_get("@attrs"))
    end

    should "update class attr with proxy if called last" do
      assert_equal({
        :class => 'list is good'
      }, subject.thing.awesome(:class => "list is").good.instance_variable_get("@attrs"))
    end

    should "proxy mixed class and id selector attrs" do
      assert_equal({
        :class => 'list is good',
        :id => "thing3"
      }, subject.thing1!.awesome({
        :class => "list is",
        :id => "thing2"
      }).good.thing3!.instance_variable_get("@attrs"))
    end

    should "not proxy if private methods are called" do
      assert_equal "<div />", subject.send(:start_tag)
      assert_equal nil, subject.send(:end_tag)
    end

  end

  class SerializeTests < BasicTests
    before do
      @output = Undies::Output.new(StringIO.new(@out = ""))
    end

    should "serialize with no child elements" do
      Undies::Template.new(Undies::Source.new do
        element(:br)
      end, {}, @output)

      assert_equal "<br />", @out
    end

    should "serialize with attrs" do
      Undies::Template.new(Undies::Source.new do
        element(:br, :class => 'big')
      end, {}, @output)

      assert_equal '<br class="big" />', @out
    end

    should "serialize with attrs that have double-quotes" do
      Undies::Template.new(Undies::Source.new do
        element(:br, :class => '"this" is double-quoted')
      end, {}, @output)

      assert_equal '<br class="&quot;this&quot; is double-quoted" />', @out
    end

    should "serialize with attrs and content" do
      Undies::Template.new(Undies::Source.new do
        element(:strong, {:class => 'big'}) { __ "Loud Noises!" }
      end, {}, @output)

      assert_equal '<strong class="big">Loud Noises!</strong>', @out
    end

    should "serialize element proxy id call" do
      Undies::Template.new(Undies::Source.new do
        element(:div).thing1! { _ "stuff" }
      end, {}, @output)

      assert_equal "<div id=\"thing1\">stuff</div>", @out
    end

    should "serialize element proxy class call" do
      Undies::Template.new(Undies::Source.new do
        element(:div).thing { _ "stuff" }
      end, {}, @output)

      assert_equal "<div class=\"thing\">stuff</div>", @out
    end

    should "serialize content from separate content blocks" do
      Undies::Template.new(Undies::Source.new do
        element(:div){ _ "stuff" }.thing1!{ _ " and more stuff" }
      end, {}, @output)

      assert_equal "<div id=\"thing1\">stuff and more stuff</div>", @out
    end

    should "serialize nested elements with pp" do
      output = Undies::Output.new(StringIO.new(@out = ""), :pp => 4)
      src = Undies::Source.new do
        element(:div) {
          element(:span) { _ "Content!" }
          __ "Raw"
          element(:span) { _ "More content" }
          element(:div).hi {
            _ "first build"
          }.there.you! {
            _ "second build"
          }
        }
      end
      templ = Undies::Template.new(src, {}, output)
      assert_equal "<div>
    <span>Content!</span>Raw
    <span>More content</span>
    <div class=\"hi there\" id=\"you\">first buildsecond build</div>
</div>", @out
    end

    # TODO: build attribute tests

  end

end
