require "assert"

require "undies/element"
require "undies/element_stack"
require "undies/template"

class Undies::Element

  class BasicTests < Assert::Context
    desc 'an element'
    before do
      @out = ""
      @es = Undies::ElementStack.new(@output = Undies::Output.new(StringIO.new(@out)))
      @e = Undies::Element.new(@es, :div)
    end
    subject { @e }

    should have_class_method :html_attrs, :start_tag, :end_tag
    should have_instance_methods :to_str, :to_ary

    should "be a Node" do
      assert_kind_of Undies::Node, subject
    end

    should "store it's name as a string" do
      assert_equal "div", subject.instance_variable_get("@name")
    end

    should "have a NodeList as its nodes" do
      assert_kind_of Undies::NodeList, subject.instance_variable_get("@nodes")
    end

    should "have its nodes be its content" do
      assert_equal subject.instance_variable_get("@nodes").object_id, subject.class.content(subject).object_id
    end

    should "have an element stack as its stack" do
      assert_kind_of Undies::ElementStack, subject.send(:instance_variable_get, "@element_stack")
    end

    should "complain if not created with an ElementStack" do
      assert_raises ArgumentError do
        Undies::Element.new([], :div)
      end
    end

  end

  class HtmlAttrsTest < Assert::Context
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
      puts attrs.inspect
      assert_match /^\s{1}/, attrs
      assert_included 'class="testing"', attrs
      assert_included 'id="test_2"', attrs
      assert_included 'nested_something="is_awesome"', attrs
    end
  end

  class EmptyTests < BasicTests
    desc 'an empty element'
    before { @e = Undies::Element.new(@es, :br) }
    subject { @e }

    should "have no nodes" do
      assert_equal([], subject.instance_variable_get("@nodes"))
    end

  end

  class SerializeTests < BasicTests

    should "serialize with no child elements" do
      element = Undies::Element.new(@es, :br)
      assert_equal "<br />", element.to_s
    end

    should "serialize with attrs" do
      element = Undies::Element.new(@es, :br, {:class => 'big'})
      assert_equal '<br class="big" />', element.to_s
    end

    should "serialize with attrs and content" do
      src = Undies::Source.new do
        element(:strong, {:class => 'big'}) { __ "Loud Noises!" }
      end
      templ = Undies::Template.new(src, {}, @output)
      assert_equal '<strong class="big">Loud Noises!</strong>', @out
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

    should "nest elements from proxy id call" do
      src = Undies::Source.new do
        element(:div).thing1! { _ "stuff" }
      end
      templ = Undies::Template.new(src, {}, @output)
      assert_equal "<div id=\"thing1\">stuff</div>", @out
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

    should "nest elements from proxy class call" do
      src = Undies::Source.new do
        element(:div).thing { _ "stuff" }
      end
      templ = Undies::Template.new(src, {}, @output)
      assert_equal "<div class=\"thing\">stuff</div>", @out
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

end
