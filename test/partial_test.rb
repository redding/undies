require "test_belt"

require "stringio"
require "undies/partial"

class Undies::Partial

  class BasicTest < Test::Unit::TestCase
    include TestBelt

    context 'partial'
    before do
      @path = 'test/templates/test.html.rb'
      @p = Undies::Partial.new @path
    end
    subject { @p }

    should "be a kind of Template" do
      assert subject.kind_of?(Undies::Template)
    end

    should "complain if no path given" do
      assert_raises ArgumentError do
        Undies::Partial.new
      end
    end

  end

  class LocalsTest < BasicTest
    before do
      @path = 'test/templates/index.html.rb'
    end

    should "know its data" do
      partial = Undies::Partial.new(@path, :name => 'A Name')
      assert_equal("A Name", partial.name)
    end

    should "know its object" do
      partial = Undies::Partial.new(@path, "thing")
      assert_equal("thing", partial.index)
    end

  end

  class StreamTest < BasicTest
    context "that is streaming"

    before do
      @output = ""
      @outstream = StringIO.new(@output)
    end


    should "should write to the stream as its being constructed" do
      Undies::Partial.new @path, @outstream
      assert_equal "<html><head></head><body><div class=\"file\">FILE!!</div></body></html>", @output
    end

  end

end
