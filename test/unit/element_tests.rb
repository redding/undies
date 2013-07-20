require "assert"
require "undies/element"

module Undies::Element

  class ElementBasicTests < Assert::Context
    desc 'a element'
    subject { Undies::Element }

    should have_instance_methods :hash_attrs, :escape_attr_value
    should have_instance_methods :open, :closed

    should "build an open element with the `open` method" do
      assert_kind_of Undies::Element::Open, subject.open(:div)
    end

    should "build a closed element with the `closed` method" do
      assert_kind_of Undies::Element::Closed, subject.closed(:br)
    end

  end

  class HashAttrsTest < ElementBasicTests
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

    should "convert a nested array to element attrs" do
      attrs = Undies::Element.hash_attrs({
        :class => "testing", :id => "test_2",
        :nested => [:something, 'is_awesome', 1]
      })
      assert_match /^\s{1}/, attrs
      assert_included 'class="testing"', attrs
      assert_included 'id="test_2"', attrs
      assert_included 'nested="something is_awesome 1"', attrs
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

end
