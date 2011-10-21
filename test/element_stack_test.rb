require "assert"

require "stringio"
require "undies/element_stack"
require "undies/node"

class Undies::ElementStack

  class BasicTests < Assert::Context
    desc 'an element stack'
    before do
      @output = Undies::Output.new(StringIO.new(""))
      @es = Undies::ElementStack.new(@output)
    end
    subject { @es }

    should have_reader :output
    should have_instance_method :push, :pop

    should "be an Array" do
      assert_kind_of Array, subject
    end

    should "empty by default" do
      assert subject.empty?
    end

    should "compain when trying to push non-elements" do
      assert_raises ArgumentError do
        subject.push Undies::Node.new
      end

      # you can append anything to an element stack, just verifying
      assert_nothing_raised do
        subject << 1
      end
    end

    should "initialize with a first item if one is given" do
      stack = Undies::ElementStack.new(@output, 12)
      assert_equal [12], stack
    end

  end

  class StreamingTests < BasicTests
    desc "when streaming"
    before do
      @stream_test_output = Undies::Output.new(@outstream = StringIO.new(@out = ""))
      @es = Undies::ElementStack.new(@stream_test_output)
    end

    should "know its output" do
      assert_same @stream_test_output, subject.output
    end

    should "stream an elements start tag when that element is pushed" do
      subject.push(Undies::Element.new(Undies::ElementStack.new(@output), "div") {})
      assert_equal "<div>", @out
    end

    should "stream an elements end tag when that element is popped" do
      elem = Undies::Element.new(Undies::ElementStack.new(@output), "div") {}
      subject.push(elem)
      popped_elem = subject.pop
      assert_equal "<div></div>", @out
      assert_same elem, popped_elem
    end

    should "stream an element with no content when pushed/popped" do
      subject.push(Undies::Element.new(Undies::ElementStack.new(subject.output), "span"))
      subject.pop
      assert_equal "<span />", @out
    end

  end

end
