require "assert"
require "stringio"
require 'undies/node_stack'

require "undies/template"

class Undies::Template



  class BasicTests < Assert::Context
    desc 'a template'
    before do
      @src = Undies::Source.new(Proc.new {})
      @output = Undies::Output.new(@outstream = StringIO.new(@out = ""))
      @t = Undies::Template.new(@src, {}, @output)
    end
    subject { @t }

    should have_class_method :source_stack, :node_stack, :flush, :escape_html
    should have_instance_methods :to_s, :element, :tag
    should have_instance_methods :_, :__
    should have_instance_methods :__yield, :__partial
    should have_instance_methods :__push, :__pop, :__flush
    should have_instance_methods :__attrs

    should "know it's node stack" do
      assert_kind_of Undies::NodeStack, subject.class.node_stack(subject)
    end

    should "complain if creating a template with no Output obj" do
      assert_raises ArgumentError do
        Undies::Template.new(@src, {})
      end
    end

    should "default the data to an empty hash if none provided" do
      assert_nothing_raised do
        Undies::Template.new(@src, @output)
      end
    end

    should "default the source to an empty Proc source if none provided" do
      assert_nothing_raised do
        Undies::Template.new(@output)
      end
      assert_equal "", @out
    end

  end



  class NodeTests < BasicTests
    desc "with text data"
    before do
      @data = "stuff & <em>more stuff</em>"
    end

    should "add the text escaped using the '_' method" do
      subject._ @data
      subject.__flush

      assert_equal subject.class.escape_html(@data), @out
    end

    should "add the text un-escaped using the '__' method" do
      subject.__ @data
      subject.__flush

      assert_equal @data, @out
    end

    should "add empty string nodes using '__' and '_' methods with no args" do
      subject._
      subject.__
      subject.__flush

      assert_equal "", @out
    end

  end



  class ElementTests < BasicTests
    desc "using the 'element' helper"

    should "stream element output" do
      subject.element(:br)
      subject.__flush

      assert_equal "<br />", @out
    end

    should "alias it with 'tag'" do
      subject.tag(:br)
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
      subject.element(:div)
      subject.__push
      subject.__attrs :class => 'test'
      subject.__pop
      subject.__flush

      assert_equal "<div class=\"test\"></div>", @out
    end

    should "should merge __attrs values with existing attrs" do
      subject.element(:div).test
      subject.__push
      subject.__attrs :id => 'this'
      subject.__pop
      subject.__flush

      assert_equal "<div class=\"test\" id=\"this\"></div>", @out
    end

    should "should merge __attrs class values by appending to the existing" do
      subject.element(:div).test
      subject.__push
      subject.__attrs :class => 'this'
      subject.__pop
      subject.__flush

      assert_equal "<div class=\"this\"></div>", @out
    end

    should "ignore __attrs values once content has been added" do
      subject.element(:div)
      subject.__push
      subject.__attrs :class => 'this'
      subject._ "hi there"
      subject._ "friend"
      subject.__attrs :title => 'missedtheboat'
      subject.__pop
      subject.__flush

      assert_equal "<div class=\"this\">hi therefriend</div>", @out
    end

    should "ignore __attrs values once child elements have been added" do
      subject.element(:div)
      subject.__push
      subject.__attrs :class => 'this'
      subject._p { subject._ "hi there" }
      subject._p { subject._ "friend" }
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
        Undies::Template.new(Undies::Source.new(Proc.new {}), {:some => 'data'}, @output)
      )
    end

    should "complain if trying to set locals that conflict with public methods" do
      assert_raises ArgumentError do
        Undies::Template.new(Undies::Source.new(Proc.new {}), {:_ => "yay!"})
      end
    end

    should "respond to each locals key with its value" do
      templ = Undies::Template.new(Undies::Source.new(Proc.new {}), {:some => 'data'}, @output)
      assert_equal "data", templ.some
    end

  end



  class StreamTests < BasicTests
    desc "that is streaming"

    before do
      outstream = StringIO.new(@output = "")
      @template = Undies::Template.new(Undies::Output.new(outstream))
    end

    should "not stream full content until Undies#flush called on the template" do
      @template._div { @template._ "Added post-init" }
      @expected_output = "<div>Added post-init</div>"

      assert_equal "", @output
      Undies::Template.flush(@template)
      assert_equal @expected_output, @output
    end

    should "should write to the stream as its being constructed" do
      @template._div.good.thing!(:type => "something")
      @template.__push
      @template.__flush

      @expected_output = "<div class=\"good\" id=\"thing\" type=\"something\">"
      assert_equal @expected_output, @output

      @template.__ "action"
      @template.__pop
      @template.__flush

      @expected_output = "<div class=\"good\" id=\"thing\" type=\"something\">action</div>"
      assert_equal @expected_output, @output
    end

  end



  class PrettyPrintTests < BasicTests

    should "generate pretty printed markup" do
      output = Undies::Output.new(@outstream, :pp => 2)
      templ = Undies::Template.new(output)

      templ._html
      templ.__push
      templ._head {}
      templ._body
      templ.__push
      templ._div
      templ.__push
      templ._ "Hi"
      templ.__pop
      templ.__pop
      templ.__pop
      templ.__flush

      assert_equal(
        %{<html>
  <head></head>
  <body>
    <div>Hi</div>
  </body>
</html>}, @out )
    end

  end



end

