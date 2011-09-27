require "test_belt"

require "stringio"
require "test/fixtures/partial_template"

class Undies::PartialTests

  class BasicTest < Test::Unit::TestCase
    include TestBelt

    context 'partial'
    before do
      @path = 'test/templates/test.html.rb'
      @p = TestPartial.new @path
    end
    subject { @p }

    should "be a kind of Template" do
      assert subject.kind_of?(Undies::Template)
    end

    should "complain if no path given" do
      assert_raises ArgumentError do
        TestPartial.new
      end
    end

  end

  class LocalsTest < BasicTest
    before do
      @path = 'test/templates/index.html.rb'
    end

    should "know its data" do
      partial = TestPartial.new(@path, :name => 'A Name')
      assert_equal("A Name", partial.name)
    end

    should "know its object" do
      partial = TestPartial.new(@path, "thing")
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
      TestPartial.new @path, @outstream
      assert_equal "<html><head></head><body><div>Hi</div></body></html>", @output
    end

  end

end
