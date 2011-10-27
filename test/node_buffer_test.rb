require "assert"

require "stringio"
require "undies/node"
require "undies/element"
require "undies/node_buffer"

class Undies::NodeStack

  class BasicTests < Assert::Context
    desc 'a node buffer'
    before do
      @nb = Undies::NodeBuffer.new
    end
    subject { @nb }

    should have_instance_method :push, :pull, :flush

    should "be an Array" do
      assert_kind_of Array, subject
    end

    should "empty by default" do
      assert subject.empty?
    end

  end

  class PushPullFlushTests < BasicTests
    before do
      @stream_test_output = Undies::Output.new(@outstream = StringIO.new(@out = ""))
    end

    should "flush nodes" do
      node = Undies::Node.new("lala")
      subject.push(node); subject.pull(@stream_test_output)
      assert_equal "lala", @out
    end

    should "flush elements with no content" do
      elem = Undies::Element.new("span")
      subject.push(elem); subject.pull(@stream_test_output)
      assert_equal "<span />", @out
    end

    should "flush elements with content" do
      elem = Undies::Element.new("div") {}
      subject.push(elem); subject.pull(@stream_test_output)
      assert_equal "<div></div>", @out
    end

  end

end
