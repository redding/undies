require "test/helper"
require "undies/template"

class Undies::Template

  class BasicTest < Test::Unit::TestCase
    include TestBelt

    context 'a template'
    subject { Undies::Template.new {} }
    should have_instance_method :to_s
    should have_instance_methods :_, :__, :element, :tag
    should have_accessor :nodes

    should "have a NodeList as its nodes" do
      assert_kind_of Undies::NodeList, subject.nodes
    end

  end



  class DataTest < BasicTest
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



  class DefinitionTest < BasicTest
    before { skip }
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
      file = 'test/test_template.html.rb'
      assert_equal(
        "<html><head></head><body><div class=\"file\">FILE!!</div></body></html>",
        Undies::Template.new(File.expand_path(file)).to_s
      )
    end

    should "generate pretty printed markup" do
      file = 'test/test_template.html.rb'
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
