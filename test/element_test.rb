require "assert"

require "undies/element"
require "undies/element_stack"
require "undies/template"

class Undies::Element

  class BasicTests < Assert::Context
    desc 'an element'
    before do
      @e = Undies::Element.new(:div)
    end
    subject { @e }

    should have_class_methods :html_attrs, :content_blocks
    should have_class_methods :content, :start_tag, :end_tag, :flush
    should have_instance_method :to_str

    should "be a Node" do
      assert_kind_of Undies::Node, subject
    end

    should "store it's name as a string" do
      assert_equal "div", subject.instance_variable_get("@name")
    end

    should "have no content itself" do
      assert_nil subject.class.content(subject)
    end

  end

  class HtmlAttrsTest < BasicTests
    desc "the element class html_attrs util"

    should "convert an empty hash to html attrs" do
      assert_equal '', Undies::Element.html_attrs({})
    end

    should "convert a basic hash to html attrs" do
      attrs = Undies::Element.html_attrs(:class => "test", :id => "test_1")
      assert_match /^\s{1}/, attrs
      assert attrs.include?('class="test"')
      assert attrs.include?('id="test_1"')
    end

    should "convert a nested hash to html attrs" do
      attrs = Undies::Element.html_attrs({
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

  end

  class SerializeTests < BasicTests
    before do
      @output = Undies::Output.new(StringIO.new(@out = ""))
    end

    should "serialize with no child elements" do
      src = Undies::Source.new do
        element(:br)
      end
      templ = Undies::Template.new(src, {}, @output)
      assert_equal "<br />", @out
    end

    should "serialize with attrs" do
      src = Undies::Source.new do
        element(:br, :class => 'big')
      end
      templ = Undies::Template.new(src, {}, @output)
      assert_equal '<br class="big" />', @out
    end

    should "serialize with attrs and content" do
      src = Undies::Source.new do
        element(:strong, {:class => 'big'}) { __ "Loud Noises!" }
      end
      templ = Undies::Template.new(src, {}, @output)
      assert_equal '<strong class="big">Loud Noises!</strong>', @out
    end

    should "serialize element proxy id call" do
      src = Undies::Source.new do
        element(:div).thing1! { _ "stuff" }
      end
      templ = Undies::Template.new(src, {}, @output)
      assert_equal "<div id=\"thing1\">stuff</div>", @out
    end

    should "serialize element proxy class call" do
      src = Undies::Source.new do
        element(:div).thing { _ "stuff" }
      end
      templ = Undies::Template.new(src, {}, @output)
      assert_equal "<div class=\"thing\">stuff</div>", @out
    end

    should "serialize content from separate content blocks" do
      src = Undies::Source.new do
        element(:div){ _ "stuff" }.thing1!{ _ " and more stuff" }
      end
      templ = Undies::Template.new(src, {}, @output)
      assert_equal "<div id=\"thing1\">stuff and more stuff</div>", @out
    end

    should "serialize nested elements with pp" do
      output = Undies::Output.new(StringIO.new(@out = ""), :pp => 4)
      src = Undies::Source.new do
        element(:div) {
          element(:span) { _ "Content!" }
          __ "Raw"
          element(:span) { _ "More content" }
        }
      end
      templ = Undies::Template.new(src, {}, output)
      assert_equal "<div>
    <span>
        Content!
    </span>
    Raw
    <span>
        More content
    </span>
</div>
", @out
    end

  end

end
