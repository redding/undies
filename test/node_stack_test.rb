require 'assert'

require 'undies/node'
require 'undies/element'
require 'test/fixtures/write_thing'

require 'undies/node_stack'

module Undies

  class NodeStackTests < Assert::Context
    desc "a NodeStack"
    before do
      @hello = Node.new "hello"
      @something = Node.new "something else"
      @hi  = Node.new("hi")
      @br  = Element.new :br
      @div = Element.new(:div) {}

      @outstream = StringIO.new(@out = "")
      @stream_test_output = Output.new(@outstream)
      @ns = NodeStack.new @stream_test_output
    end
    subject { @ns }

    should have_class_method :create
    should have_readers :stack, :cache, :buffer
    should have_instance_methods :current, :size, :level, :empty?, :first, :last
    should have_instance_methods :push, :pop, :node, :flush
    should have_instance_methods :flush_cache, :cached_node

    should "be empty by default" do
      assert_empty subject
    end

    should "have an empty buffer by default" do
      assert_empty subject.buffer
    end

    should "have an empty cache by default" do
      assert_empty subject.cache
    end

  end


  class StackTests < NodeStackTests

    should "push nodes onto the stack" do
      assert_nothing_raised do
        subject.push(@hello)
        subject.push(@something)
      end

      assert_equal 2, subject.size
    end

    should "know its level (should be one less than the array's size)" do
      assert_equal 0, subject.level
      subject.push(@hello)
      assert_equal 1, subject.level
    end

    should "fetch the last item in the array with the current method" do
      subject.push(@hello)
      subject.push(@something)

      assert_same @something, subject.current
    end

    should "remove the last item in the array with the pop method" do
      subject.push(@hello)
      subject.push(@something)

      assert_equal 2, subject.size

      node = subject.pop
      assert_same @something, node
      assert_equal 1, subject.size
    end

  end


  class CacheTests < NodeStackTests

    should "add nodes to its cache using the #node method" do
      subject.node(@hi)
      assert_equal 1, subject.cache.size
      assert_equal @hi, subject.cache.first
    end

    should "push the current cached node onto the stack when caching a new node" do
      subject.node(@br)
      assert_equal 1, subject.cache.size
      assert_equal @br, subject.cache.first
      assert_equal 0, subject.size

      subject.node(@div)
      assert_equal 1, subject.cache.size
      assert_equal @div, subject.cache.first
    end

    should "call the node's builds when flushed from cache" do
      build = "build"
      subject.node(Element.new(:div) { build += " called" })
      subject.flush

      assert_equal "build called", build
    end

  end


  class BufferItemTests < Assert::Context
    before do
      @wbi = NodeStack::BufferItem.new(@write_thing = WriteThing.new, :hi)
    end
    subject { @wbi }

    should have_reader :item
    should have_accessors :write_method, :level
    should have_instance_methods :prefix, :to_s

    should "set and default its attributes" do
      assert_equal @write_thing, subject.item
      assert_equal 'hi', subject.write_method
      assert_equal 0, subject.level
    end

    should "set custom attributes" do
      witem = NodeStack::BufferItem.new(@write_thing, :hello, 2)
      assert_equal @write_thing, witem.item
      assert_equal 'hello', witem.write_method
      assert_equal 2, witem.level
    end

    should "set custom attributes after init" do
      subject.write_method = "hithere"
      assert_equal 'hithere', subject.write_method

      subject.level = 2
      assert_equal 2, subject.level
    end

    should "return its item's write_method value on to_s" do
      subject.write_method = :hithere
      assert_equal 'hithere', subject.to_s
    end

    should "return its item's prefix value" do
      assert_equal "\n  ", subject.prefix(2, 1)
    end

  end


  class BufferTests < Assert::Context
    desc "a WriteBuffer"
    before do
      @write_thing = WriteThing.new
      @outstream = StringIO.new(@out = "")
      @stream_test_output = Undies::Output.new(@outstream, :pp => 2)

      @wb = NodeStack::Buffer.new @stream_test_output
    end
    subject { @wb }

    should have_reader :current, :output
    should have_instance_method :empty?, :size, :push, :flush, :first, :last

    should "have no items by default" do
      assert_empty subject
    end

    should "push items onto the stack" do
      assert_nothing_raised do
        subject.push(NodeStack::BufferItem.new(@write_thing, :hi))
      end

      assert_equal 1, subject.size
    end

    should "return the first item in the array with the current method" do
      assert_equal nil, subject.current
      subject.push(item1 = NodeStack::BufferItem.new(@write_thing, :hi))
      assert_equal item1, subject.current
    end

    should "write out the items when pushing new items and flushing" do
      assert_equal "", @out
      subject.push(NodeStack::BufferItem.new(@write_thing, :hi))
      assert_equal "", @out
      subject.push(NodeStack::BufferItem.new(@write_thing, :hello, 1))
      assert_equal "hi", @out
      subject.push(NodeStack::BufferItem.new(@write_thing, :hithere, 1))
      assert_equal "hi\n  hello", @out
      subject.push(NodeStack::BufferItem.new(@write_thing, :hi))
      assert_equal "hi\n  hello\n  hithere", @out
      subject.flush
      assert_equal "hi\n  hello\n  hitherehi", @out
    end

  end


  class PushPopFlushTests < NodeStackTests

    should "buffer a node's start_tag when it is pushed" do
      assert_equal "", @out
      subject.push(@hello)

      assert_equal 1, subject.buffer.size
      assert_equal @hello, subject.buffer.first.item
      assert_equal 'start_tag', subject.buffer.first.write_method
    end

    should "buffer a node's content and end_tag when it is popped" do
      assert_equal "", @out
      subject.push(@hello)
      subject.pop
      assert_equal 1, subject.buffer.size
      assert_equal @hello, subject.buffer.first.item
      assert_equal 'end_tag', subject.buffer.first.write_method
    end

    should "buffer at the stack level" do
      subject.push(@hello)
      subject.push(@hi)

      assert_equal 1, subject.buffer.size
      assert_equal @hi, subject.buffer.first.item
      assert_equal 1, subject.buffer.first.level
    end

  end


end
