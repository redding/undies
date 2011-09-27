require "test_belt"

require "stringio"
require "undies/template"

class Undies::Template

  class BasicTest < Test::Unit::TestCase
    include TestBelt

    context 'a template'
    subject { Undies::Template.new {} }
    should have_instance_method :to_s, :escape_html
    should have_instance_methods :_, :__, :element, :tag
    should have_accessor :nodes

    should "have a NodeList as its nodes" do
      assert_kind_of Undies::NodeList, subject.nodes
    end

    should "have no io stream by default" do
      assert_nil subject.send(:___io)
    end

    should "maintain the template's scope throughout content blocks" do
      templ = Undies::Template.new do
        _div {
          _div {
            __ self.object_id
          }
        }
      end
      assert_equal "<div><div>#{templ.object_id}</div></div>", templ.to_s
    end

    should "generate pretty printed markup" do
      file = 'test/templates/test.html.rb'
      assert_equal(
        %{<html>
  <head>
  </head>
  <body>
    <div>
      Hi
    </div>
  </body>
</html>
},
        Undies::Template.new(File.expand_path(file)).to_s(2)
      )
    end

  end



  class NodeTest < BasicTest
    context "with text data"
    before do
      @data = "stuff & <em>more stuff</em>"
    end

    should "return a text node using the '__' and '_' methods" do
      assert_kind_of Undies::Node, subject.__(@data)
      assert_kind_of Undies::Node, subject._(@data)
    end

    should "also add the node using the '__' and '_' methods" do
      subject.__(@data)
      assert_equal 1, subject.nodes.size
      subject._(@data)
      assert_equal 2, subject.nodes.size
    end

    should "add the text un-escaped using the '__' method" do
      assert_equal @data, subject.__(@data).to_s
    end

    should "add the text escaped using the '_' method" do
      assert_equal subject.send(:escape_html, @data), subject._(@data).to_s
    end

    should "add empty string nodes using '__' and '_' methods with no args" do
      assert_equal "", subject._.to_s
      assert_equal "", subject.__.to_s
    end

  end



  class ElementTest < BasicTest
    context "using the 'element' helper"

    should "return an Element object" do
      assert_equal Undies::Element.new(Undies::ElementStack.new, :br), subject.element(:br)
    end

    should "alias it with 'tag'" do
      assert_equal subject.element(:br), subject.tag(:br)
    end

    should "add a new Element object" do
      subject.element(:br)
      assert_equal 1, subject.nodes.size
      assert_equal Undies::Element.new(Undies::ElementStack.new, :br), subject.nodes.first
    end

    should "respond to underscore-prefix methods" do
      assert subject.respond_to?(:_div)
    end

    should "respond to underscore-prefix methods as element methods" do
      assert_equal subject._div, subject.element(:div)
    end

    should "not respond to element methods without an underscore-prefix" do
      assert !subject.respond_to?(:div)
      assert_raises NoMethodError do
        subject.div
      end
    end

  end



  class LocalsTest < BasicTest

    should "only accept the data if it is a Hash" do
      assert_raises ArgumentError do
        (Undies::Template.new("some_data") {}).some
      end
      assert_raises ArgumentError do
        (Undies::Template.new('test/templates/test.html.rb', "some_data")).some
      end
      assert_respond_to(
        (Undies::Template.new(:some => "data") {}),
        :some
      )
      assert_respond_to(
        Undies::Template.new('test/templates/test.html.rb', :some => "data"),
        :some
      )
    end

    should "complain if trying to set locals that conflict with public methods" do
      assert_raises ArgumentError do
        Undies::Template.new(:_ => "yay!") {}
      end
    end

    should "respond to each locals key with its value" do
      templ = Undies::Template.new(:some => "data") {}
      assert_equal "data", templ.some
    end

    should "be able to access its locals in the template definition" do
      templ = Undies::Template.new(:name => "awesome") do
        _div {
          _div { _ name }
        }
      end
      assert_equal "<div><div>awesome</div></div>", templ.to_s
    end

  end



  class DefinitionTest < BasicTest
    setup do
      @expected_output = "<html><head></head><body><div>Hi</div></body></html>"
      @proc = Proc.new do
        _html {
          _head {}
          _body {
            _div { _ "Hi" }
          }
        }
      end
      @content_proc = Proc.new do
        _div { _ "Hi" }
      end
      @layout_proc = Proc.new do
        _html { _head {}; _body { yield if block_given? } }
      end
      @layout_file = File.expand_path "test/templates/layout.html.rb"
      @content_file = File.expand_path "test/templates/content.html.rb"
      @test_content_file = File.expand_path "test/templates/test.html.rb"
    end

    should "generate markup given the content in a passed block" do
      template = Undies::Template.new(&@proc)
      assert_equal @expected_output, template.to_s
    end

    should "complain if given a proc both as the first arg and passed as a block" do
      assert_raises ArgumentError do
        Undies::Template.new(@proc) do
          _div { _ "Should not render b/c argument error" }
        end
      end
    end

    should "generate markup given the content in a file, even if passed a block" do
      template_no_block = Undies::Template.new(@test_content_file)
      template_w_block = Undies::Template.new(@test_content_file) do
        _div { _ "Should not render b/c template prefers a file" }
      end
      assert_equal @expected_output, template_no_block.to_s
      assert_equal @expected_output, template_w_block.to_s
    end

    should "generate markup given the layout in a file and the content in a passed block" do
      template = Undies::Template.new(@layout_file) do
        _div { _ "Hi" }
      end
      assert_equal @expected_output, template.to_s
    end

    should "generate markup given the layout in a Proc and the content in a Proc as first arg" do
      template = Undies::Template.new(@content_proc, @layout_file)
      assert_equal @expected_output, template.to_s
    end

    should "generate markup given the layout in a file and the content in a file" do
      template = Undies::Template.new(@content_file, @layout_file)
      assert_equal @expected_output, template.to_s
    end

    should "complain if given the layout in a Proc and the content in a passed block" do
      assert_raises ArgumentError do
        Undies::Template.new(@layout_proc) do
          _div { _ "Hi" }
        end
      end
    end

    should "complain given the layout in a Proc and the content in a Proc as first arg" do
      assert_raises ArgumentError do
        Undies::Template.new(@content_proc, @layout_proc)
      end
    end

    should "complain given the layout in a Proc and the content in a file" do
      assert_raises ArgumentError do
        Undies::Template.new(@content_file, @layout_proc)
      end
    end

  end



  class StreamTest < BasicTest
    context "that is streaming"

    before do
      @output = ""
      @outstream = StringIO.new(@output)
    end

    should "should write to the stream as its being constructed" do
      templ = Undies::Template.new(@outstream) do
        _div {
          _div.good.thing!(:type => "something") {
            __ "good streaming action"
          }
        }
      end
      assert_equal "<div><div class=\"good\" id=\"thing\" type=\"something\">good streaming action</div></div>", @output
    end

  end

end

