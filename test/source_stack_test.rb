require "assert"

require "undies/source_stack"

class Undies::SourceStack

  class BasicTests < Assert::Context
    desc 'a source stack'
    before do
      @content_file = File.expand_path('test/templates/content.html.rb')
      @content_file_source = Undies::Source.new(@content_file)

      @hi_proc = Proc.new do
        _div { _ "Hi!" }
      end
      @hi_proc_source = Undies::Source.new(&@hi_proc)
      @hi_proc_content_file_source = Undies::Source.new({:layout => @content_file}, &@hi_proc)

      @ss = Undies::SourceStack.new(@hi_proc_content_file_source)
    end
    subject { @ss }

    should have_instance_method :pop

    should "be an Array" do
      assert_kind_of Array, subject
    end

    should "base itself on the source" do
      assert_equal @hi_proc_content_file_source, subject.first
      assert_equal @hi_proc_source, Undies::SourceStack.new(@hi_proc_source).first
    end

    should "should stack on the source's layouts" do
      assert_equal @content_file_source, subject.last

      content = Undies::Source.new(@content_file, {
        :layout => (lay1 = Undies::Source.new(@content_file, {
          :layout => (lay2 = Undies::Source.new(@content_file))
        }))
      })

      assert_equal [content, lay1, lay2], Undies::SourceStack.new(content)
    end

  end

end
