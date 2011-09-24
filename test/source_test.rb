require "test_belt"
require "undies/source"

class Undies::Source

  class BasicTest < Test::Unit::TestCase
    include TestBelt

    context 'a source'
    subject { Undies::Source.new(&Proc.new {}) }
    should have_readers :file, :block
    should have_instance_methods :layout?, :file_data

    should "complain if no file or block given" do
      assert_raises ArgumentError do
        Undies::Source.new
      end
    end

    should "complain if given file does not exist" do
      assert_raises ArgumentError do
        Undies::Source.new "noexist.html.rb"
      end
    end

  end

  class BlockTest < BasicTest
    context 'from a block'
    subject { Undies::Source.new(&Proc.new {}) }

    should "have a block source and no file source" do
      assert subject.block
      assert_nil subject.file
      assert_nil subject.file_data
      assert_equal false, subject.layout?
    end

  end

  class FileTest < BasicTest
    context 'from a file'
    subject do
      file = 'test/templates/test.html.rb'
      Undies::Source.new(File.expand_path(file))
    end

    should "have a file source and no block source" do
      assert_nil subject.block
      assert subject.file
      assert subject.file_data
      assert_equal false, subject.layout?
    end

  end

  class BothTest < BasicTest
    context 'from both a file and block'
    subject do
      file = 'test/templates/test.html.rb'
      Undies::Source.new(File.expand_path(file), &Proc.new {})
    end

    should "have a file source and a block source" do
      assert subject.block
      assert subject.file
      assert subject.file_data
      assert_equal true, subject.layout?
    end

  end

end
