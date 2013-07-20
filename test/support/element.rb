require 'undies/element'

module Undies::Element
  module TestHelpers

    def proxy_css_methods
      called_from = caller.first
      Assert::Macro.new("have style attributes") do

        should "respond to any method ending in '!' as an id proxy", called_from do
          assert subject.respond_to?(:asdgasdg!)
        end

        should "proxy id attr with methods ending in '!'", called_from do
          assert_equal({
            :id => 'thing1'
          }, subject.thing1!.instance_variable_get("@attrs"))
        end

        should "proxy id attr with last method call ending in '!'", called_from do
          assert_equal({
            :id => 'thing2'
          }, subject.thing1!.thing2!.instance_variable_get("@attrs"))
        end

        should "set id attr to explicit if called last ", called_from do
          assert_equal({
            :id => 'thing3'
          }, subject.thing1!.thing2!(:id => 'thing3').instance_variable_get("@attrs"))
        end

        should "set id attr to proxy if called last", called_from do
          assert_equal({
            :id => 'thing1'
          }, subject.thing2!(:id => 'thing3').thing1!.instance_variable_get("@attrs"))
        end

        should "respond to any other method as a class proxy", called_from do
          assert_respond_to :asdgasdg, subject
        end

        should "proxy single html class attr", called_from do
          assert_equal({
            :class => 'thing'
          }, subject.thing.instance_variable_get("@attrs"))
        end

        should "proxy multi html class attrs", called_from do
          assert_equal({
            :class => 'list thing awesome'
          }, subject.list.thing.awesome.instance_variable_get("@attrs"))
        end

        should "set class attr with explicit if called last ", called_from do
          assert_equal({
            :class => 'list'
          }, subject.thing.awesome(:class => "list").instance_variable_get("@attrs"))
        end

        should "update class attr with proxy if called last", called_from do
          assert_equal({
            :class => 'list is good'
          }, subject.thing.awesome(:class => "list is").good.instance_variable_get("@attrs"))
        end

        should "proxy mixed class and id selector attrs", called_from do
          subject.thing1!.awesome({:class => "list is", :id => "thing2"}).good.thing3!

          assert_equal({
            :class => 'list is good',
            :id => "thing3"
          }, subject.instance_variable_get("@attrs"))
        end

      end
    end

  end
end
