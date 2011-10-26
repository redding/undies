require "assert"

require "stringio"
require "undies/template"

class Undies::Template

  class BasicTests < Assert::Context
    desc 'a template'
    before do
      src = Undies::Source.new(Proc.new {})
      @outstream = StringIO.new(@out = "")
      @output = Undies::Output.new(@outstream)

      @r = Undies::RenderData.new(src, @output)
      @t = Undies::Template.new(src, {}, @output)
    end
    subject { @t }

    should have_instance_method  :to_s
    should have_instance_methods :element, :tag, :escape_html
    should have_instance_methods :_, :__
    should have_instance_method  :__yield
    should have_class_method :render_data

    should "store and retrieve render data objects using a class level accessor" do
      assert_nothing_raised do
        subject.class.set_render_data(subject, @r)
      end
      assert_same @r, subject.class.render_data(subject)
    end

    should "maintain the template's scope throughout content blocks" do
      templ = Undies::Template.new(Undies::Source.new do
        _div {
          _div {
            __ self.object_id
          }
        }
      end, {}, @output)
      assert_equal "<div><div>#{templ.object_id}</div></div>", @out
    end

    should "generate pretty printed markup" do
      file = 'test/templates/test.html.rb'
      output = Undies::Output.new(@outstream, :pp => 2)
      Undies::Template.new(Undies::Source.new(File.expand_path(file)), {}, output)
      assert_equal(
        %{
<html>
  <head>
  </head>
  <body>
    <div>
      Hi
    </div>
  </body>
</html>},
        @out
      )
    end

  end

  class NodeTests < BasicTests
    desc "with text data"
    before do
      @data = "stuff & <em>more stuff</em>"
    end

    should "add the text un-escaped using the '__' method" do
      Undies::Template.new(Undies::Source.new do
        __ data
      end, {:data => @data}, @output)
      assert_equal @data, @out
    end

    should "add the text escaped using the '_' method" do
      Undies::Template.new(Undies::Source.new do
        _ data
      end, {:data => @data}, @output)
      assert_equal subject.send(:escape_html, @data), @out
    end

    should "add empty string nodes using '__' and '_' methods with no args" do
      Undies::Template.new(Undies::Source.new do
        _
        __
      end, {:data => @data}, @output)
      assert_equal "", @out
    end

  end

  class ElementTests < BasicTests
    desc "using the 'element' helper"

    should "stream element output" do
      Undies::Template.new(Undies::Source.new do
        element(:br)
      end, {}, @output)
      assert_equal "<br />", @out
    end

    should "alias it with 'tag'" do
      Undies::Template.new(Undies::Source.new do
        tag(:br)
      end, {}, @output)
      assert_equal "<br />", @out
    end

    should "respond to underscore-prefix methods" do
      assert subject.respond_to?(:_br)
    end

    should "respond to underscore-prefix methods as element methods" do
      Undies::Template.new(Undies::Source.new do
        _br
      end, {}, @output)
      assert_equal "<br />", @out
    end

    should "not respond to element methods without an underscore-prefix" do
      assert !subject.respond_to?(:div)
      assert_raises NoMethodError do
        subject.div
      end
    end

  end

  class LocalDataTests < BasicTests

    should "only accept the data if it is a Hash" do
      assert_raises ArgumentError do
        Undies::Template.new(Undies::Source.new(Proc.new {}), "some data")
      end
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

    should "be able to access its locals in the template definition" do
      src = Undies::Source.new do
        _div {
          _div { _ name }
        }
      end
      Undies::Template.new(src, {:name => "awesome"}, @output)
      assert_equal "<div><div>awesome</div></div>", @out
    end

  end

  class LayoutTests < BasicTests
    setup do
      @expected_output = "<html><head></head><body><div>Hi</div></body></html>"

      @layout_proc = Proc.new do
        _html {
          _head {}
          _body {
            __yield
          }
        }
      end
      @layout_file = File.expand_path "test/templates/layout.html.rb"

      @content_proc = Proc.new do
        _div { _ "Hi" }
      end
      @content_file = File.expand_path "test/templates/content.html.rb"

      @cp_lp_source = Undies::Source.new(:layout => @layout_proc, &@content_proc)
      @cp_lf_source = Undies::Source.new(:layout => @layout_file, &@content_proc)
      @cf_lp_source = Undies::Source.new(@content_file, :layout => @layout_proc)
      @cf_lf_source = Undies::Source.new(@content_file, :layout => @layout_file)
    end

    should "generate markup given proc content in a proc layout" do
      Undies::Template.new(@cp_lp_source, {}, @output)
      assert_equal @expected_output, @out
    end

    should "generate markup given proc content in a layout file" do
      Undies::Template.new(@cp_lf_source, {}, @output)
      assert_equal @expected_output, @out
    end

    should "generate markup given a content file in a proc layout" do
      Undies::Template.new(@cf_lp_source, {}, @output)
      assert_equal @expected_output, @out
    end

    should "generate markup given a content file in a layout file" do
      Undies::Template.new(@cf_lf_source, {}, @output)
      assert_equal @expected_output, @out
    end

  end

  class StreamTests < BasicTests
    desc "that is streaming"

    before do
      outstream = StringIO.new(@output = "")
      src = Undies::Source.new do
        _div.good.thing!(:type => "something") {
          __ "action"
        }
      end
      @expected_output = "<div class=\"good\" id=\"thing\" type=\"something\">action</div>"

      Undies::Template.new(src, {}, Undies::Output.new(outstream))
    end

    should "should write to the stream as its being constructed" do
      assert_equal @expected_output, @output
    end

  end

end

