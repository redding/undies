require "assert"

require "undies/source"

class Undies::Source

  class BasicTests < Assert::Context
    desc 'a source'
    before do
      @content_file = File.expand_path('test/support/templates/content.html.rb')
      @content_file_data = File.read(@content_file)
      @content_file_source = Undies::Source.new(@content_file)

      @hi_proc = Proc.new do
        _div { _ "Hi!" }
      end
      @hi_proc_source = Undies::Source.new(&@hi_proc)

      @named_source_name = :cf
      @named_source = Undies.named_source(@named_source_name, @content_file)
      @named_source_source = Undies.source(@named_source_name)

      @s = Undies::Source.new {}
    end
    subject { @s }

    should have_readers :source, :data, :layout
    should have_writers :args, :source, :layout
    should have_instance_method :file?, :layouts, :layout_sources

    should "know whether its a file source or not" do
      assert @content_file_source.file?
      assert_not @hi_proc_source.file?
    end

  end

  class SourceWriterTests < BasicTests
    before do
      @does_not_exist_path = '/path/does/not/exist'
    end

    should "write its source value" do
      subject.source = @hi_proc
      assert_equal @hi_proc, subject.source
      assert_equal @content_file, (subject.source = @content_file)
    end

    should "complain if writing a nil source" do
      assert_raises(ArgumentError) { subject.source = nil }
    end

    should "complain if writing a file source with a file that does not exist" do
      assert_raises(ArgumentError) { subject.source = @does_not_exist_path }
    end

    should "set its data to the contents of the file when writing a file source" do
      subject.source = @content_file
      assert_equal @content_file_data, subject.data
    end

    should "set its data to the proc when writing a proc source" do
      subject.source = @hi_proc
      assert_equal @hi_proc, subject.data
    end

  end

  class LayoutWriterTests < BasicTests

    should "write nil layout values" do
      subject.layout = nil
      assert_nil subject.layout
    end

    should "write source layouts given a source" do
      subject.layout = @hi_proc_source
      assert_equal @hi_proc_source, subject.layout
    end

    should "write proc source layouts given a proc" do
      subject.layout = @hi_proc
      assert_equal @hi_proc_source, subject.layout
    end

    should "write file source layouts given a file path" do
      subject.layout = @content_file
      assert_equal @content_file_source, subject.layout
    end

    should "write named source layouts given a named source" do
      subject.layout = @named_source
      assert_equal @named_source_source, subject.layout
    end

    should "complain if trying to write an invalid layout value" do
      assert_raises(ArgumentError) { subject.layout = 345 }
      assert_raises(ArgumentError) { subject.layout = true }
    end

    should "know its layouts, layout sources" do
      assert_equal [], subject.layouts
      assert_equal [], subject.layout_sources

      subject.layout = (lay1 = Undies::Source.new(@content_file, {
        :layout => (lay2 = Undies::Source.new(@content_file, {
          :layout => (lay3 = Undies::Source.new(@content_file))
        }))
      }))

      assert_equal [lay1, lay2, lay3], subject.layouts
      assert_equal [@content_file, @content_file, @content_file], subject.layout_sources
    end

  end

  class ArgsParserTests < BasicTests

    should "parse block arg as proc source" do
      s = Undies::Source.new(&@hi_proc)
      assert_not s.file?
      assert_equal @hi_proc, s.source
      assert_equal @hi_proc, s.data
    end

    should "parse path arg as a file source" do
      s = Undies::Source.new(@content_file)
      assert s.file?
      assert_equal @content_file, s.source
      assert_equal @content_file_data, s.data
    end

    should "parse opts arg" do
      opts = {:layout => @content_file_source}
      assert_equal @content_file_source, Undies::Source.new(@content_file, opts).layout
      assert_equal @content_file_source, Undies::Source.new(opts, &@hi_proc).layout
    end

    should "parse named source as named source args" do
      s = Undies::Source.new(@named_source)
      assert_equal @named_source_source, s
    end

    should "parse named source layouts" do
      s = Undies::Source.new({:layout => @named_source}, &@hi_proc)
      assert_equal @named_source_source, s.layout
    end

    should "complain if building a source from an unknown named source" do
      assert_raises(ArgumentError) { Undies::Source.new(:wtf) }
    end

  end

end
