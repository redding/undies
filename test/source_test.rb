require "test/helper"
require "undies/source"

class Undies::Source

  class BasicTest < Test::Unit::TestCase
    include TestBelt

    context 'a source'
    subject { Undies::Source.new(nil, Proc.new {}) }
    should have_instance_method :file?
    should have_readers :file, :block, :data

    should "complain if no file or block given" do
      assert_raises ArgumentError do
        Undies::Source.new
      end
    end

    should "complain if no block given and file does not exist" do
      assert_raises ArgumentError do
        Undies::Template.new "noexist.html.rb"
      end
    end


  end

  class BlockTest < BasicTest
    context 'from a block'
    subject { Undies::Source.new(nil, Proc.new {}) }

    should "not be a file source" do
      assert !subject.file?
    end
  end

  class FileTest < BasicTest
    context 'from a file'
    subject do
      file = 'test/test_template.html.rb'
      Undies::Source.new(File.expand_path(file))
    end

    should "be a file source" do
      assert subject.file?
    end
  end

end
