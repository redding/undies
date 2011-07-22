require "test/helper"
require "undies/template"

class Undies::Template

  class BasicTest < Test::Unit::TestCase
    include TestBelt

    context 'template'
    subject { Undies::Template.new {} }
    should have_instance_methods :to_s
  end

  class DefinitionTest < BasicTest
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
