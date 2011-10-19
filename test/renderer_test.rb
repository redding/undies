require "assert"

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

    should have_readers :io, :pp
    should have_accessors :source_stack
    should have_instance_methods :source=, :element_stack, :nodes

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

  end

end
