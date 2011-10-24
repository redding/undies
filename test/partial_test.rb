require "assert"

require "stringio"
require "test/fixtures/partial_template"

class Undies::PartialTests

  class BasicTests < Assert::Context
    desc 'partial'
    before do
      @path = 'test/templates/test.html.rb'
      @outstream = StringIO.new(@out = "")
      @output = Undies::Output.new(@outstream)

      @p = TestPartial.new @path, {}, @output
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

    should "should write to the stream as its being constructed" do
      assert_equal "<html><head></head><body><div>Hi</div></body></html>", @out
    end

  end

  class LocalsTests < BasicTests
    before do
      @path = 'test/templates/index.html.rb'
    end

    should "know its data" do
      partial = TestPartial.new(@path, {:name => 'A Name'}, @output)
      assert_equal("A Name", partial.name)
    end

    should "know its object" do
      partial = TestPartial.new(@path, "thing", @output)
      assert_equal("thing", partial.index)
    end

    should "know its object and other data" do
      partial = TestPartial.new(@path, "thing", {:name => 'A Name'}, @output)
      assert_equal("thing", partial.index)
      assert_equal("A Name", partial.name)
    end

  end

end
