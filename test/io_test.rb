require "assert"
require 'stringio'
require "undies/io"

class Undies::IO

  class BasicTests < Assert::Context
    desc 'render data'
    before do
      @io = Undies::IO.new(@out = "")
    end
    subject { @io }

    should have_readers :stream, :indent, :newline
    should have_writer :options
    should have_accessor :level
    should have_instance_methods :line_indent, :<<

    should have_readers :node_stack, :current
    should have_instance_methods :push, :push!, :pop, :empty?

    should "know its stream" do
      assert_same @out, subject.stream
    end

    should "default to no pretty printing" do
      assert_equal 0,  subject.indent
      assert_equal "", subject.newline
    end

    should "default to level 0" do
      assert_equal 0, subject.level
    end

    should "default with an empty node_stack" do
      assert_empty subject.node_stack
      assert_nil subject.current
    end

    should "write raw data directly to the stream" do
      subject << "Raw data"
      assert_equal "Raw data", @out
    end

  end



  class PrettyPrintTests < BasicTests
    desc "when pretty printing"
    before do
      subject.options = {:pp => 2, :level => 1}
    end

    should "know its pp settings" do
      assert_equal 2,    subject.indent
      assert_equal 1,    subject.level
      assert_equal "\n", subject.newline
    end

    should "pretty print line indents" do
      assert_equal "  hi", subject.line_indent + "hi"

      subject.level += 1
      assert_equal "    hello", subject.line_indent + "hello"
      assert_equal "manual level down", subject.line_indent(-2) + "manual level down"

      subject.level -= 1
      assert_equal "  implicit level down", subject.line_indent + 'implicit level down'
    end

  end



  class NodeStackTests < BasicTests

    should "push to, pop from, and refer to the current thing on the stack" do
      subject.push("lala")
      assert_equal "lala", subject.current
      assert_equal 1, subject.level

      subject.pop
      assert_nil subject.current
      assert_equal 0, subject.level

      subject.push!("boohoo")
      assert_equal "boohoo", subject.current
      assert_equal 0, subject.level
    end

    should "be empty if its node stack is empty" do
      assert_empty subject.node_stack
      assert_empty subject

      subject.push("lala")

      assert_not_empty subject.node_stack
      assert_not_empty subject
    end


  end

end
