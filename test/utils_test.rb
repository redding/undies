require "test/helper"
require "undies/utils"

class Undies::Utils

  class Test < Test::Unit::TestCase
    include TestBelt

    context "the util"
    subject { Undies::Utils }

    should have_instance_methods :selector_opts

    [ :selector_opts ].
    each do |meth|
      define_method(meth) do |*args|
        Undies::Utils.send(meth.to_s, *args)
      end
    end

  end

  class SelectorTest < Test
    context "'selector'"

    should "not parse any opts if not selector" do
      assert_equal({}, selector_opts)
      assert_equal({}, selector_opts(''))
    end

    should "parse html id attr" do
      assert_equal({
        :id => 'thing1'
      }, selector_opts('#thing1'))
      assert_equal({
        :id => 'thing2'
      }, selector_opts('#thing1#thing2'))
    end

    should "parse single html class attr" do
      assert_equal({
        :class => 'thing'
      }, selector_opts('.thing'))
    end

    should "assume html id attr if no selector syntax" do
      assert_equal({
        :id => 'the-thing'
      }, selector_opts('the-thing'))
    end

    should "parse multi html class attrs" do
      assert_equal({
        :class => 'awesome thing'
      }, selector_opts('.awesome.thing'))
      assert_equal({
        :class => 'list thing awesome'
      }, selector_opts('.list.thing.awesome'))
    end

    should "parse mixed class and id selector attrs" do
      [ '#tim.awesome.thing',
        '.awesome#tim.thing',
        '.awesome.thing#tim'
      ].each do |s|
        assert_equal({
          :class => 'awesome thing',
          :id => 'tim'
        }, selector_opts(s))
      end
    end
  end

end
