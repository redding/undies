require 'assert'

require 'undies/node'
require 'undies/element'
require 'test/fixtures/write_thing'

require 'undies/node_stack'

module Undies

  class NodeStackTests < Assert::Context
    desc "a NodeStack"
    before do
      skip
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
    should have_readers :stack, :cached_node, :output
    should have_instance_methods :current, :size, :level, :empty?, :first, :last
    should have_instance_methods :push, :pop, :node, :flush
    should have_instance_methods :clear_cached

    should "be empty by default" do
      assert_empty subject
    end

    should "have an empty cache by default" do
      assert_nil subject.cached_node
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
      assert_equal @hi, subject.cached_node
    end

    should "push the current cached node onto the stack when caching a new node" do
      subject.node(@br)
      assert_equal @br, subject.cached_node
      assert_equal 0, subject.size

      subject.node(@div)
      assert_equal @div, subject.cached_node
    end

    should "call the node's builds when flushed from cache" do
      build = "build"
      subject.node(Element.new(:div) { build += " called" })
      subject.flush

      assert_equal "build called", build
    end

  end



end
