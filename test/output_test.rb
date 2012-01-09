require "assert"

require 'stringio'
require 'undies/node'
require 'undies/element'

require "undies/output"

class Undies::Output

  class BasicTests < Assert::Context
    desc 'render data'
    before do
      @io = StringIO.new(@out = "")
      @output = Undies::Output.new(@io)
    end
    subject { @output }

    should have_readers :io, :options, :pp, :node_buffer
    should have_accessor :pp_use_indent
    should have_instance_methods :options=, :<<, :pp_level
    should have_instance_methods :node, :flush

    should "know its stream" do
      assert_same @io, subject.io
    end

    # TODO: switch to call it a node buffer
    should "have an empty node buffer" do
      assert_kind_of Undies::NodeBuffer, subject.node_buffer
      assert_equal 0, subject.node_buffer.size
    end

    should "default to no pretty printing" do
      assert_nil subject.pp
    end

    should "default to pretty printing level 0" do
      assert_equal 0, subject.pp_level
    end

    should "stream data" do
      subject << "some data"
      assert_equal @out, "some data"
    end

    should "not stream nil data" do
      subject << nil
      assert_equal @out, ""
    end

  end

  class PrettyPrintTests < BasicTests
    desc "when pretty printing"
    before do
      subject.options = {:pp => 2}
    end

    should "know its pp indent amount" do
      assert_equal 2, subject.pp
    end

    should "start pp at level 0 by default" do
      assert_equal 0, subject.pp_level
    end

    should "pretty print stream data" do
      subject << "some data"
      assert_equal "\nsome data", @out

      subject.pp_level +=1
      subject << "indented data"
      assert_equal "\nsome data\n  indented data", @out

      subject.pp_level -= 1
      subject << "more data"
      assert_equal "\nsome data\n  indented data\nmore data", @out
    end

    should "pretty print nodes" do
      subject.node(Undies::Node.new("lala")); subject.flush
      assert_equal "\nlala", @out
    end

    should "pretty print at a given level if directed to" do
      subject.options = {:pp => 2, :pp_level => 2}
      subject.node(Undies::Node.new("lala")); subject.flush
      assert_equal "\n    lala", @out
    end

    should "pretty print elements with no content" do
      subject.node(Undies::Element.new("span")); subject.flush
      assert_equal "\n<span />", @out
    end

    should "keep node content on the same line" do
      subject.node(Undies::Element.new("div") {
        subject.node Undies::Node.new("hi")
        subject.node Undies::Node.new("there")
      })
      subject.node(Undies::Element.new("div") {
        subject.node Undies::Node.new("")
        subject.node Undies::Node.new("hi")
        subject.node Undies::Node.new("again")
      })
      subject.flush

      assert_equal "\n<div>hithere</div>\n<div>hiagain</div>", @out
    end

  end


  class NodeHandlingTests < BasicTests

    should "create and append nodes" do
      subject.node Undies::Node.new "hey!"
      assert_equal 1, subject.node_buffer.size
    end

    should "create and append elements" do
      subject.node Undies::Element.new(:div)
      assert_equal 1, subject.node_buffer.size
    end

  end

end
