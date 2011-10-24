require "assert"

require "stringio"
require "undies/template"

class Undies::Template

  class BasicTests < Assert::Context
    desc 'a template'
    before do
      src = Undies::Source.new(Proc.new {})
      @outstream = StringIO.new(@output = "")
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
        subject.class.render_data(subject, @r)
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
      assert_equal "<div><div>#{templ.object_id}</div></div>", templ.to_s
    end

    should "generate pretty printed markup" do
      file = 'test/templates/test.html.rb'
      output = Undies::Output.new(@outstream, :pp => 2)
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
        Undies::Template.new(Undies::Source.new(File.expand_path(file)), {}, output).to_s
      )
    end

  end

  class NodeTests < BasicTests
    desc "with text data"
    before do
      @data = "stuff & <em>more stuff</em>"
    end

    should "return a text node using the '__' and '_' methods" do
      assert_kind_of Undies::Node, subject.__(@data)
      assert_kind_of Undies::Node, subject._(@data)
    end

    should "also add the node using the '__' and '_' methods" do
      subject.__(@data)
      assert_equal 1, subject.class.render_data(subject).nodes.size
      subject._(@data)
      assert_equal 2, subject.class.render_data(subject).nodes.size
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

  class ElementTests < BasicTests
    desc "using the 'element' helper"
    before do
      @es = Undies::ElementStack.new(subject.instance_variable_get("@___output___"))
    end

    should "return an Element object" do
      assert_equal Undies::Element.new(@es, :br), subject.element(:br)
    end

    should "alias it with 'tag'" do
      assert_equal subject.element(:br), subject.tag(:br)
    end

    should "add a new Element object" do
      subject.element(:br)
      assert_equal 1, subject.class.render_data(subject).nodes.size
      assert_equal Undies::Element.new(@es, :br), subject.class.render_data(subject).nodes.first
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
      templ = Undies::Template.new(src, {:name => "awesome"}, @output)
      assert_equal "<div><div>awesome</div></div>", templ.to_s
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
      assert_equal @expected_output, Undies::Template.new(@cp_lp_source, {}, @output).to_s
    end

    should "generate markup given proc content in a layout file" do
      assert_equal @expected_output, Undies::Template.new(@cp_lf_source, {}, @output).to_s
    end

    should "generate markup given a content file in a proc layout" do
      assert_equal @expected_output, Undies::Template.new(@cf_lp_source, {}, @output).to_s
    end

    should "generate markup given a content file in a layout file" do
      assert_equal @expected_output, Undies::Template.new(@cf_lf_source, {}, @output).to_s
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

