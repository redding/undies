require "assert"

require "undies/node"
require "undies/node_buffer"

class Undies::Node

  class BasicTests < Assert::Context
    desc 'a node'
    before { @n = Undies::Node.new("a text node here") }
    subject { @n }

    should have_class_methods :content, :flush

    should "know it's content" do
      assert_equal "a text node here", subject.class.content(subject)
    end

    should "know it's start/end tags" do
      assert_nil subject.instance_variable_get("@start_tag")
      assert_nil subject.instance_variable_get("@end_tag")
    end

    should "output its content when flushed" do
      output = Undies::Output.new(StringIO.new(out = ""))
      subject.class.flush(output, subject)

      assert_equal "a text node here", out
    end

    should "force pp when flushed if directed" do
      output = Undies::Output.new(StringIO.new(out = ""), :pp => 2, :pp_level => 1)
      output.pp_use_indent = false
      Undies::Node.flush(output, Undies::Node.new("should be pp", {:force_pp => true}))

      assert_equal "\n  should be pp", out
    end

  end

end
