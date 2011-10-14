require "assert"
require "undies/source"

class Undies::Source

  class BasicTests < Assert::Context
    desc 'a source'
    before { @s = Undies::Source.new(Proc.new {}) }
    subject { @s }

    should have_readers :source, :data
    should have_instance_method :file?

    should "complain if no file or block given" do
      assert_raises ArgumentError do
        Undies::Source.new
      end
    end

    should "complain if no block given and file does not exist" do
      assert_raises ArgumentError do
        Undies::Source.new "noexist.html.rb"
      end
    end

  end

  class BlockTests < BasicTests
    desc 'from a block'
    subject { Undies::Source.new(Proc.new {}) }

    should "not be a file source" do
      assert !subject.file?
    end

  end

  class FileTests < BasicTests
    desc 'from a file'
    subject do
      file = 'test/templates/test.html.rb'
      Undies::Source.new(File.expand_path(file))
    end

    should "be a file source" do
      assert subject.file?
    end

  end

end
