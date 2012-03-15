require "assert"

require 'stringio'
require 'undies/node'
require 'undies/element'
require 'undies/node_stack'
require 'test/fixtures/write_thing'

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
    should have_writer :options
    should have_accessor :pp_level
    should have_instance_method :write

    should "know its stream" do
      assert_same @io, subject.io
    end

    should "default to no pretty printing" do
      assert_equal 0, subject.pp
    end

    should "default to pretty printing level 0" do
      assert_equal 0, subject.pp_level
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
      subject.write(WriteThing.new, :hi, 0)
      assert_equal "hi", @out

      subject.pp_level +=1
      subject.write(WriteThing.new, :hello, 0)
      assert_equal "hi\n  hello", @out

      subject.pp_level -= 1
      subject.write(WriteThing.new, :hithere, 0)
      assert_equal "hi\n  hellohithere", @out
    end

  end

end
