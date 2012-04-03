require "assert"
require "undies/template"

class Undies::Template



  class BasicTests < Assert::Context
    desc 'a template'
    before do
      @src = Undies::Source.new(Proc.new {})
      @io = Undies::IO.new(@out = "")
      @t = Undies::Template.new(@src, {}, @io)
    end
    subject { @t }

    should have_class_methods    :flush, :escape_html
    should have_instance_methods :__yield, :__partial
    should have_instance_methods :__push, :__pop, :__flush
    should have_instance_methods :__attrs

    # capture api
    should have_instance_methods :raw

    # streaming api
    should have_instance_methods :_, :__element, :__tag

    should "complain if creating a template with no IO obj" do
      assert_raises ArgumentError do
        Undies::Template.new(@src, {})
      end
    end

    should "default the data to an empty hash if none provided" do
      assert_nothing_raised do
        Undies::Template.new(@src, @io)
      end
    end

    should "default the source to an empty Proc source if none provided" do
      assert_nothing_raised do
        Undies::Template.new(@io)
      end
      assert_equal "", @out
    end

    should "push a root node onto its IO" do
      assert_kind_of Undies::RootNode, @io.current
    end

  end



  class PlainTextTests < BasicTests
    before do
      @data = "stuff & <em>more stuff</em>"
    end

    should have_instance_methods :raw

    should "add the text un-escaped using the 'raw' method" do
      assert_equal @data, subject.raw(@data)
    end

    should "escape the text using the Template#escape_html method" do
      assert_equal "stuff &amp; &lt;em&gt;more stuff&lt;&#x2F;em&gt;", Undies::Template.escape_html(@data)
    end

  end



  class PlainTextTests < BasicTests
    desc "with text data"
    before do
      @data = "stuff & <em>more stuff</em>"
    end

    should "add the text escaped using the '_' method" do
      subject._ @data
      subject.__flush

      assert_equal subject.class.escape_html(@data), @out
    end

  end



  class ElementTests < BasicTests
    desc "using the 'element' helper"

    should "stream element output" do
      subject.__element(:br)
      subject.__flush

      assert_equal "<br />", @out
    end

    should "alias it with 'tag'" do
      subject.__tag(:br)
      subject.__flush

      assert_equal "<br />", @out
    end

    should "respond to underscore-prefix methods" do
      assert subject.respond_to?(:_br)
    end

    should "respond to underscore-prefix methods as element methods" do
      subject._br
      subject.__flush

      assert_equal "<br />", @out
    end

    should "not respond to element methods without an underscore-prefix" do
      assert !subject.respond_to?(:div)
      assert_raises NoMethodError do
        subject.div
      end
    end

  end



  class BuildAttrsTests < BasicTests

    should "modify attributes during a build using the __attrs method" do
      subject.__element(:div)
      subject.__push
      subject.__attrs :class => 'test'
      subject.__pop
      subject.__flush

      assert_equal "<div class=\"test\"></div>", @out
    end

    should "should merge __attrs values with existing attrs" do
      subject.__element(:div).test
      subject.__push
      subject.__attrs :id => 'this'
      subject.__pop
      subject.__flush

      assert_equal "<div class=\"test\" id=\"this\"></div>", @out
    end

    should "should merge __attrs class values by appending to the existing" do
      subject.__element(:div).test
      subject.__push
      subject.__attrs :class => 'this'
      subject.__pop
      subject.__flush

      assert_equal "<div class=\"this\"></div>", @out
    end

    should "add __attrs even though content has been added" do
      subject.__element(:div, 'hi there', 'friend')
      subject.__push
      subject.__attrs :class => 'this'
      subject.__pop
      subject.__flush

      assert_equal "<div class=\"this\">hi therefriend</div>", @out
    end

    should "ignore __attrs values once child elements have been added" do
      subject.__element(:div)
      subject.__push
      subject.__attrs :class => 'this'
      subject._p 'hi there'
      subject._p 'friend'
      subject.__attrs :title => 'missedtheboat'
      subject.__pop
      subject.__flush

      assert_equal "<div class=\"this\"><p>hi there</p><p>friend</p></div>", @out
    end

  end



  class LocalDataTests < BasicTests
    should "only accept the data if it is a Hash" do
      assert_respond_to(
        :some,
        Undies::Template.new(Undies::Source.new(Proc.new {}), {:some => 'data'}, @io)
      )
    end

    should "complain if trying to set locals that conflict with public methods" do
      assert_raises ArgumentError do
        Undies::Template.new(Undies::Source.new(Proc.new {}), {:_ => "yay!"}, @io)
      end
    end

    should "respond to each locals key with its value" do
      templ = Undies::Template.new(Undies::Source.new(Proc.new {}), {:some => 'data'}, @io)
      assert_equal "data", templ.some
    end

  end



  class StreamTests < BasicTests
    desc "that is streaming"

    before do
      @template = Undies::Template.new(Undies::IO.new(@output = ""))
    end

    should "not stream full content until Undies#flush called on the template" do
      @template._div "Added"
      @expected_output = "<div>Added</div>"

      assert_equal "", @output
      Undies::Template.flush(@template)
      assert_equal @expected_output, @output
    end

    should "should write to the stream as its being constructed" do
      @template._div.good.thing!(:type => "something")
      @template.__push
      @template._p 'hi'
      @template.__flush

      @expected_output = "<div class=\"good\" id=\"thing\" type=\"something\"><p>hi</p>"
      assert_equal @expected_output, @output

      @template._p "action"
      @template.__pop
      @template.__flush

      @expected_output = "<div class=\"good\" id=\"thing\" type=\"something\"><p>hi</p><p>action</p></div>"
      assert_equal @expected_output, @output
    end

  end



  class PrettyPrintTests < BasicTests

    should "generate pretty printed markup" do
      output = Undies::IO.new(@out = "", :pp => 2)
      templ = Undies::Template.new(output)

      templ._html
      templ.__push
      templ._head {}
      templ._body
      templ.__push
      templ._div "Hi"
      templ.__pop
      templ.__pop
      templ.__flush

      assert_equal(
        %{<html>
  <head></head>
  <body>
    <div>Hi</div>
  </body>
</html>
}, @out )
    end

  end



end

