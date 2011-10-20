require "assert"
require 'stringio'

require "undies/renderer"

class Undies::Renderer

  class BasicTests < Assert::Context
    desc 'a renderer'
    before do
      @content_file = File.expand_path('test/templates/content.html.rb')
      @content_file_data = File.read(@content_file)
      @content_file_source = Undies::Source.new(@content_file)

      @hi_proc = Proc.new do
        _div { _ "Hi!" }
      end
      @hi_proc_source = Undies::Source.new(&@hi_proc)
      @hi_proc_content_file_source = Undies::Source.new({:layout => @countent_file}, &@hi_proc)

      @r = Undies::Renderer.new(@hi_proc_source)
    end
    subject { @r }

    should have_readers :io, :pp, :nodes, :source_stack, :element_stack
    should have_instance_methods :source=, :options=, :to_s
    should have_instance_methods :append, :node, :element

    should "have a source stack based on its source" do
      assert_kind_of Undies::SourceStack, subject.source_stack
      assert_equal Undies::SourceStack.new(@hi_proc_source), subject.source_stack

      r = Undies::Renderer.new(@hi_proc_content_file_source)
      assert_equal Undies::SourceStack.new(@hi_proc_content_file_source), r.source_stack
    end

    should "have an element stack where the renderer is the base (and only) element on the stack" do
      assert_kind_of Undies::ElementStack, subject.element_stack
      assert_equal 1, subject.element_stack.size
      assert_equal subject, subject.element_stack.first
    end

    should "have a node list that is empty to start" do
      assert_kind_of Undies::NodeList, subject.nodes
    end

    should "have no option values by default" do
      assert_nil subject.io
      assert_nil subject.pp
    end


  end

  class OptionsTests < BasicTests
    before do
      @io = StringIO.new("")
      subject.options = {:io => @io}
    end

    should "complain if setting options to something not a Hash" do
      assert_nothing_raised do
        subject.options = {}
      end
      assert_raises ArgumentError do
        subject.options = 12
      end
    end

    should "set its io stream from an :io option" do
      assert_equal @io, subject.io
    end

    should "create its element stack with the io stream option" do
      assert_equal subject.io, subject.element_stack.io
    end

    should "set its pretty print from an :pp option" do
      subject.options = {:pp => 2}
      assert_equal 2, subject.pp
    end

    should "not override option values when not present in an options hash" do
      assert_equal @io, subject.io
      subject.options = {:blahblah => "bbbb"}
      assert_equal @io, subject.io
    end

  end

  class NodeHandlingTests < BasicTests
    before do
      @hey = Undies::Node.new "hey!"

      outstream = StringIO.new(@output = "")
      src = Undies::Source.new do
        _div.good.thing!(:type => "something") {
          __ "action"
        }
      end
      @expected_output = "hey!"

      @r = Undies::Renderer.new(src, :io => outstream)
    end

    should "append nodes with the 'append' method" do
      subject.append(@hey)
      assert_equal 1, subject.element_stack.last.instance_variable_get("@nodes").size
    end

    should "return the node when appending" do
      assert_equal @hey.object_id, subject.append(@hey).object_id
    end

    should "create and append nodes" do
      assert_equal @hey, subject.node("hey!")
      assert_equal 1, subject.element_stack.last.instance_variable_get("@nodes").size
    end

    should "create and append elements" do
      elem = Undies::Element.new(subject.element_stack, :div)
      assert_equal elem, subject.element(:div)
      assert_equal 1, subject.element_stack.last.instance_variable_get("@nodes").size
    end

  end


end
