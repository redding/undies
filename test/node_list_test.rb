require "assert"

require "undies/node_list"
require "undies/node"

class Undies::NodeList

  class BasicTests < Assert::Context
    desc 'a node list'
    before { @nl = Undies::NodeList.new }
    subject { @nl }

    should have_instance_method :append
    should have_reader :io

    should "be an Array" do
      assert_kind_of ::Array, subject
    end

    should "always init empty" do
      assert_equal 0, subject.size
      assert_equal 0, Undies::NodeList.new([1,2,3]).size
    end

    should "complain if you try to append something other than a node" do
      assert_raises ArgumentError do
        subject.append('hey!')
      end
      assert_raises ArgumentError do
        subject << 'hey!'
      end
      assert_nothing_raised do
        subject.append(Undies::Node.new('hey!'))
        subject.append(Undies::NodeList.new)
        subject << Undies::Node.new('hey!')
      end
    end

  end

  class NodeHandlingTests < BasicTests
    before do
      @hey = Undies::Node.new "hey!"
      @you = Undies::Node.new " you..."
      @there = Undies::Node.new " there."
      @node_list = Undies::NodeList.new
      @node_list.append(@you)
      @node_list.append(@there)
    end

    should "append nodes with the 'append' method" do
      subject.append(@hey)
      assert_equal 1, subject.size
    end

    should "return the node when appending" do
      assert_equal @hey.object_id, subject.append(@hey).object_id
    end

    should "serialize to a string" do
      assert_equal " you... there.", @node_list.to_s

      to_serialize = Undies::NodeList.new
      to_serialize.append(@hey)
      to_serialize.append(@node_list)
      assert_equal "hey! you... there.", to_serialize.to_s
    end

  end

  class StreamingTests < NodeHandlingTests
    desc "when streaming"
    before do
      @stream_list = Undies::NodeList.new(@outstream = StringIO.new(@output = ""))
    end

    should "know its stream" do
      assert_same @outstream, @stream_list.io
    end

    should "stream a node when appended" do
      assert_equal "", @output
      @stream_list.append(@hey)
      assert_equal "hey!", @output
      @stream_list.append(@you)
      assert_equal "hey! you...", @output
      @stream_list.append(@there)
      assert_equal "hey! you... there.", @output
    end

  end


end
