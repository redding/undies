require "assert"

require "undies/named_source"

class Undies::NamedSource

  class BasicTests < Assert::Context
    desc 'a named source'
    before do
      @content_file = File.expand_path('test/templates/content.html.rb')
      @content_file_data = File.read(@content_file)
      @content_file_nsource = Undies::NamedSource.new(@content_file)
      @content_file_source = Undies::Source.new(@content_file)
      @hi_proc = Proc.new do
        _div { _ "Hi!" }
      end
      @hi_proc_nsource = Undies::NamedSource.new(&@hi_proc)

      @s = Undies::NamedSource.new() {}
    end
    subject { @s }

    should have_accessors :file, :opts, :proc, :args

  end

  class AccessorTests < BasicTests
    before do
      subject.file = @content_file
      subject.opts = {:layout => :another}
      subject.proc = @hi_proc
      @subject_args = [@content_file, {:layout => :another}, @hi_proc]

      @another = Undies::NamedSource.new(@content_file, &@hi_proc)
      @another_args = [@content_file, {}, @hi_proc]
    end


    should "write its accessors" do
      assert_equal @content_file, subject.file
      assert_equal({:layout => :another}, subject.opts)
      assert_equal @hi_proc, subject.proc

      assert_equal @content_file, @another.file
      assert_equal({}, @another.opts)
      assert_equal @hi_proc, @another.proc
    end

    should "build its args from its accessors" do
      assert_equal @subject_args, subject.args
      assert_equal @another_args, @another.args
    end

  end

  class UndiesTests < BasicTests
    before do
      Undies.named_sources.clear
    end
    after do
      Undies.named_sources.clear
    end

    should "provide a singleton method for accessing named sources" do
      assert_respond_to :named_sources, Undies
      assert_respond_to :named_source, Undies
      assert_respond_to :source, Undies
    end

    should "access the singleton set of named sources" do
      assert_equal({}, Undies.named_sources)
    end

    should "build new and retrieve named sources from the singleton" do
      assert_equal @content_file_nsource, Undies.named_source(:cf, @content_file)
      assert_equal @content_file_nsource, Undies.named_source(:cf)
    end

    should "build retrieve sources from the source singleton accessor" do
      Undies.named_source(:cf, @content_file)
      assert_equal @content_file_source, Undies.source(:cf)
    end

    should "not retrieve unknown named sources" do
      assert_nil Undies.named_source(:wtf)
      assert_nil Undies.source(:wtf)
    end

  end

end
