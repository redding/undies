require "test_belt"
require "undies/partial"

class Undies::Partial

  class BasicTest < Test::Unit::TestCase
    include TestBelt

    context 'partial'
    subject { Undies::Partial.new 'test/templates/index.html.rb' }

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

end
