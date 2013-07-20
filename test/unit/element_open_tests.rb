require "assert"
require "undies/element"

require 'test/support/element'

module Undies::Element

  class OpenBasicTests < Assert::Context
    desc 'an open element'
    before do
      @e = Undies::Element::Open.new(:div)
    end
    subject { @e }

    should have_instance_methods :__start_tag, :__content, :__build, :__end_tag
    should have_instance_methods :to_s

    should "know its name and store it as a string" do
      assert_equal "div", subject.instance_variable_get("@name")
    end

    should "have no attrs by default" do
      assert_empty subject.instance_variable_get("@attrs")
    end

    should "have no content by default" do
      assert_empty subject.instance_variable_get("@content")
    end

    should "have no build by default" do
      assert_nil subject.instance_variable_get("@build")
    end

  end



  class OpenCSSProxyTests < OpenBasicTests
    extend TestHelpers

    should proxy_css_methods
  end



  class OpenSerializeTests < OpenBasicTests

    should "serialize with no attrs, content, or build" do
      elem = Undies::Element::Open.new(:div)
      assert_equal "<div></div>", elem.to_s
    end

    should "serialize with attrs" do
      elem = Undies::Element::Open.new(:div, :class => 'big')
      assert_equal "<div class=\"big\"></div>", elem.to_s
    end

    should "serialize with escaped attrs content" do
      elem = Undies::Element::Open.new(:div, :class => '"this" is double-quoted')
      assert_equal "<div class=\"&quot;this&quot; is double-quoted\"></div>", elem.to_s
    end

    should "serialize with a single piece of content" do
      elem = Undies::Element::Open.new(:div, "hi")
      assert_equal "<div>hi</div>", elem.to_s
    end

    should "serialize with multiple pieces of content joined" do
      elem = Undies::Element::Open.new(:div, "hi", ' there', ' you')
      assert_equal "<div>hi there you</div>", elem.to_s
    end

    should "serialize with escaped content" do
      elem = Undies::Element::Open.new(:div, "stuff & <em>more stuff</em>")
      assert_equal "<div>stuff &amp; &lt;em&gt;more stuff&lt;&#x2F;em&gt;</div>", elem.to_s
    end

    should "serialize with raw content" do
      elem = Undies::Element::Open.new(:div, Undies::Raw.new("stuff & <em>more stuff</em>"))
      assert_equal "<div>stuff & <em>more stuff</em></div>", elem.to_s
    end

    should "serialize element proxy id call" do
      elem = Undies::Element::Open.new(:div, 'stuff').thing1!
      assert_equal "<div id=\"thing1\">stuff</div>", elem.to_s
    end

    should "serialize element proxy id call with content" do
      elem = Undies::Element::Open.new(:div).thing1! 'proxy stuff'
      assert_equal "<div id=\"thing1\">proxy stuff</div>", elem.to_s
    end

    should "serialize element proxy class call" do
      # calling a private method as public to test private methods not
      # polluting public method_missing scope
      elem = Undies::Element::Open.new(:div, 'stuff').proxy
      assert_equal "<div class=\"proxy\">stuff</div>", elem.to_s
    end

  end

end
