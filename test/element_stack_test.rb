require "assert"

require "stringio"
require "undies/element_stack"
require "undies/node"

class Undies::ElementStack

  class BasicTests < Assert::Context
    desc 'an element stack'
    before { @es = Undies::ElementStack.new }
    subject { @es }

    should have_instance_method :push, :pop
    should have_reader :io

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

      assert_nothing_raised do
        subject << 1
      end
    end

    should "initialize with a first item if one is given" do
      stack = Undies::ElementStack.new(12)
      assert_equal [12], stack
    end

  end

  class StreamingTests < BasicTests
    desc "when streaming"
    before do
      @output = ""
      @outstream = StringIO.new(@output)
      @es = Undies::ElementStack.new(nil, @outstream)
    end

    should "know its stream" do
      assert_same @outstream, subject.io
    end

    should "stream an elements start tag when that element is pushed" do
      subject.push(Undies::Element.new(Undies::ElementStack.new, "div") {})
      assert_equal "<div>", @output
    end

    should "stream an elements end tag when that element is popped" do
      elem = Undies::Element.new(Undies::ElementStack.new, "div") {}
      subject.push(elem)
      popped_elem = subject.pop
      assert_equal "<div></div>", @output
      assert_same elem, popped_elem
    end

    should "stream an element with no content when pushed/popped" do
      subject.push(Undies::Element.new(Undies::ElementStack.new, "span"))
      subject.pop
      assert_equal "<span />", @output
    end

  end

end
