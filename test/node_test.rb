require "assert"

require "undies/node"

class Undies::Node

  class BasicTests < Assert::Context
    desc 'a node'
    before { @n = Undies::Node.new("a text node here") }
    subject { @n }

    should have_class_methods :content, :start_tag, :end_tag, :flush

    should "know it's content" do
      assert_equal "a text node here", subject.class.content(subject)
    end

    should "know it's start/end tags" do
      assert_nil subject.class.start_tag(subject)
      assert_nil subject.class.end_tag(subject)
    end

    should "output its content when flushed" do
      output = Undies::Output.new(StringIO.new(out = ""))
      ns = Undies::ElementStack.new(output)
      subject.class.flush(subject, ns)

      assert_equal "a text node here", out
    end

  end

end
