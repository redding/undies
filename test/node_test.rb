require "assert"

require "undies/output"
require "undies/node"

class Undies::Node

  class BasicTests < Assert::Context
    desc 'a node'
    before do
      @output = Undies::Output.new(StringIO.new(@out = ""))
      @n = Undies::Node.new("a text node here")
    end
    subject { @n }

    should have_class_methods :start_tag, :end_tag, :content, :builds, :prefix

    should "have no start/end tags" do
      assert_empty subject.class.start_tag(subject)
      assert_empty subject.class.end_tag(subject)
    end

    should "have content" do
      assert_equal "a text node here", subject.class.content(subject)
    end

    should "have no builds" do
      assert_empty subject.class.builds(subject)
    end

    should "have no prefix, ever" do
      assert_empty subject.class.prefix(subject)
    end

  end

end
