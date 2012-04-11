require "assert"
require 'undies/io'
require "undies/element"


module Undies::Element

  class ClosedBasicTests < Assert::Context
    desc 'a closed element'
    before do
      @ec = Undies::Element::Closed.new(:br)
    end
    subject { @ec }

    should have_instance_methods :__start_tag, :__content, :__build, :__end_tag
    should have_instance_methods :to_s

    should "know its name and store it as a string" do
      assert_equal "br", subject.instance_variable_get("@name")
    end

    should "have no attrs by default" do
      assert_empty subject.instance_variable_get("@attrs")
    end

  end



  class ClosedCSSProxyTests < ClosedBasicTests
    extend CSSProxyMacro

    should proxy_css_methods
  end



  class ClosedSerializeTests < ClosedBasicTests

    should "serialize with no attrs" do
      elem = Undies::Element::Closed.new(:br)
      assert_equal "<br />", elem.to_s
    end

    should "serialize with attrs" do
      elem = Undies::Element::Closed.new(:br, :class => 'big')
      assert_equal "<br class=\"big\" />", elem.to_s
    end

    should "serialize with attrs that have double-quotes" do
      elem = Undies::Element::Closed.new(:br, :class => '"this" is double-quoted')
      assert_equal "<br class=\"&quot;this&quot; is double-quoted\" />", elem.to_s
    end

    should "serialize element proxy id call" do
      elem = Undies::Element::Closed.new(:br).thing1!
      assert_equal "<br id=\"thing1\" />", elem.to_s
    end

    should "serialize element proxy class call" do
      # calling a private method as public to test private methods not
      # polluting public method_missing scope
      elem = Undies::Element::Closed.new(:br).proxy
      assert_equal "<br class=\"proxy\" />", elem.to_s
    end

  end

end
