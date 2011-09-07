require "test_belt"
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
      assert_raises NoMethodError do
        (Undies::Template.new("some_data") {}).some
      end
      assert_raises NoMethodError do
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

  end



  class DefinitionTest < BasicTest

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

    should "be able to access its locals in the template definition" do
      templ = Undies::Template.new(:name => "awesome") do
        _div {
          _div { _ name }
        }
      end
      assert_equal "<div><div>awesome</div></div>", templ.to_s
    end

    should "generate markup given a block" do
      assert_equal(
        "<html><head></head><body><div class=\"loud element\" id=\"header\">YEA!!</div></body></html>",
        Undies::Template.new do
          _html {
            _head {}
            _body {
              _div.header!.loud.element {
                __ "YEA!!"
              }
            }
          }
        end.to_s
      )
    end

    should "generate markup given a file" do
      file = 'test/templates/test.html.rb'
      assert_equal(
        "<html><head></head><body><div class=\"file\">FILE!!</div></body></html>",
        Undies::Template.new(File.expand_path(file)).to_s
      )
    end

    should "generate pretty printed markup" do
      file = 'test/templates/test.html.rb'
      assert_equal(
        %{<html>
  <head>
  </head>
  <body>
    <div class="file">
      FILE!!
    </div>
  </body>
</html>
},
        Undies::Template.new(File.expand_path(file)).to_s(2)
      )
    end
  end

end
