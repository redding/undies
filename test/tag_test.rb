require "test/helper"
require "undies/tag"

class Undies::Tag



  class BasicTest < Test::Unit::TestCase
    include TestBelt

    context 'a tag'
    subject { Undies::Tag.new(:div) }
    should have_instance_methods :to_s, :attrs
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
    context "when serialized"

    should "buffer an empty html tag with no attrs" do
      tag = Undies::Tag.new(:br)
      assert_equal "<br />", tag.to_s
    end

    should "buffer an html tag with attrs" do
      tag = Undies::Tag.new(:br, {:class => 'big'})
      assert_equal '<br class="big" />', tag.to_s
    end

    should "buffer an html tag with attrs and content" do
      tag = Undies::Tag.new(:strong, {:class => 'big'}) { __ "Loud Noises!" }
      assert_equal '<strong class="big">Loud Noises!</strong>', tag.to_s
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
