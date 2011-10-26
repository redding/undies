require "assert"

require "stringio"
require "undies/node"
require "undies/element"
require "undies/node_stack"

class Undies::NodeStack

  class BasicTests < Assert::Context
    desc 'a node stack'
    before do
      @output = Undies::Output.new(StringIO.new(""))
      @es = Undies::NodeStack.new(@output)
    end
    subject { @es }

    should have_reader :output
    should have_instance_method :push, :pop

    should "be an Array" do
      assert_kind_of Array, subject
    end

    should "know its output" do
      assert_same @output, subject.output
    end

    should "empty by default" do
      assert subject.empty?
    end

  end

  class StreamingTests < BasicTests
    desc "when streaming"
    before do
      @stream_test_output = Undies::Output.new(@outstream = StringIO.new(@out = ""))
      @es = Undies::NodeStack.new(@stream_test_output)
    end

    should "stream a node when popped" do
      node = Undies::Node.new("lala")
      subject.push(node); subject.pop
      assert_equal "lala", @out
    end

    should "stream an element with no content when popped" do
      elem = Undies::Element.new("span")
      subject.push(elem); subject.pop
      assert_equal "<span />", @out
    end

    should "stream an element with content when that element is popped" do
      elem = Undies::Element.new("div") {}
      subject.push(elem); subject.pop
      assert_equal "<div></div>", @out
    end

  end

end
