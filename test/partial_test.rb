require "test/helper"
require "undies/partial"

class Undies::Partial

  class BasicTest < Test::Unit::TestCase
    include TestBelt

    context 'partial'
    subject { Undies::Template.new {} }

    should "be a kind of Template" do
      assert subject.kind_of?(Undies::Template)
    end

  end

  class DefinitionTest < BasicTest

    should "generate markup given a file" do
      file = 'test/test_template.html.rb'
      assert_equal(
        "<html><head></head><body><div class=\"file\">FILE!!</div></body></html>",
        Undies::Partial.new(File.expand_path(file)).to_s
      )
    end

  end

end
