require "test_belt"

require "undies/element"
require "undies/element_stack"
require "undies/template"

class Undies::Element



  class BasicTest < Test::Unit::TestCase
    include TestBelt

    context 'an element'
    before { @e = Undies::Element.new(Undies::ElementStack.new, :div) }
    subject { @e }
    should have_readers :name, :attrs
    should have_accessor :nodes

    should "be a Node" do
      assert_kind_of Undies::Node, subject
    end

    should "store it's name as a string" do
      assert_equal "div", subject.name
    end

    should "have a NodeList as its nodes" do
      assert_kind_of Undies::NodeList, subject.nodes
    end

    should "have its nodes be its content" do
      assert_equal subject.nodes.object_id, subject.content.object_id
    end

    should "have an element stack as its stack" do
      assert_kind_of Undies::ElementStack, subject.send(:instance_variable_get, "@stack")
    end

    should "complain is not created with an ElementStack" do
      assert_raises ArgumentError do
        Undies::Element.new([], :div)
      end
    end

  end



  class EmptyTest < Test::Unit::TestCase
    include TestBelt
    context 'an empty element'
    before { @e = Undies::Element.new(Undies::ElementStack.new, :br) }
    subject { @e }

    should "have no nodes" do
      assert_equal([], subject.nodes)
    end

  end



  class HtmlAttrsTest < BasicTest
    context "html_attrs util"

    should "convert an empty hash to html attrs" do
      assert_equal('', subject.send(:html_attrs, {}))
    end

    should "convert a basic hash to html attrs" do
      attrs = subject.send(:html_attrs, :class => "test", :id => "test_1")
      assert_match /^\s{1}/, attrs
      assert attrs.include?('class="test"')
      assert attrs.include?('id="test_1"')
    end

    should "convert a nested hash to html attrs" do
      attrs = subject.send(:html_attrs, {
        :class => "testing", :id => "test_2",
        :nested => {:something => 'is_awesome'}
      })
      assert_match /^\s{1}/, attrs
      assert attrs.include?('class="testing"')
      assert attrs.include?('id="test_2"')
      assert attrs.include?('nested="somethingis_awesome"')
    end
  end



  class SerializeTest < BasicTest
    should "serialize with no child elements" do
      element = Undies::Element.new(Undies::ElementStack.new, :br)
      assert_equal "<br />", element.to_s
    end

    should "serialize with attrs" do
      element = Undies::Element.new(Undies::ElementStack.new, :br, {:class => 'big'})
      assert_equal '<br class="big" />', element.to_s
    end

    should "serialize with attrs and content" do
      templ = Undies::Template.new do
        element(:strong, {:class => 'big'}) { __ "Loud Noises!" }
      end
      assert_equal '<strong class="big">Loud Noises!</strong>', templ.to_s
    end
  end



  class CSSProxyTest < BasicTest

    should "respond to any method ending in '!' as an id proxy" do
      assert subject.respond_to?(:asdgasdg!)
    end

    should "proxy id attr with methods ending in '!'" do
      assert_equal({
        :id => 'thing1'
      }, subject.thing1!.attrs)
    end

    should "nest elements from proxy id call" do
      templ = Undies::Template.new do
        element(:div).thing1! { _ "stuff" }
      end
      assert_equal "<div id=\"thing1\">stuff</div>", templ.to_s
    end

    should "proxy id attr with last method call ending in '!'" do
      assert_equal({
        :id => 'thing2'
      }, subject.thing1!.thing2!.attrs)
    end

    should "set id attr to explicit if called last " do
      assert_equal({
        :id => 'thing3'
      }, subject.thing1!.thing2!(:id => 'thing3').attrs)
    end

    should "set id attr to proxy if called last" do
      assert_equal({
        :id => 'thing1'
      }, subject.thing2!(:id => 'thing3').thing1!.attrs)
    end

    should "respond to any other method as a class proxy" do
      assert subject.respond_to?(:asdgasdg)
    end

    should "proxy single html class attr" do
      assert_equal({
        :class => 'thing'
      }, subject.thing.attrs)
    end

    should "nest elements from proxy class call" do
      templ = Undies::Template.new do
        element(:div).thing { _ "stuff" }
      end
      assert_equal "<div class=\"thing\">stuff</div>", templ.to_s
    end

    should "proxy multi html class attrs" do
      assert_equal({
        :class => 'list thing awesome'
      }, subject.list.thing.awesome.attrs)
    end

    should "set class attr with explicit if called last " do
      assert_equal({
        :class => 'list'
      }, subject.thing.awesome(:class => "list").attrs)
    end

    should "update class attr with proxy if called last" do
      assert_equal({
        :class => 'list is good'
      }, subject.thing.awesome(:class => "list is").good.attrs)
    end

    should "proxy mixed class and id selector attrs" do
      assert_equal({
        :class => 'list is good',
        :id => "thing3"
      }, subject.thing1!.awesome({
        :class => "list is",
        :id => "thing2"
      }).good.thing3!.attrs)
    end

  end



end
