require "assert"

require 'stringio'
require "undies/output"

class Undies::Output

  class BasicTests < Assert::Context
    desc 'render data'
    before do
      @io = StringIO.new(@out = "")
      @output = Undies::Output.new(@io)
    end
    subject { @output }

    should have_readers :io, :pp
    should have_instance_methods :options=, :<<, :pp_level

    should "know its stream" do
      assert_same @io, subject.io
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

  end


end
