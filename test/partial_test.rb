require "test/helper"
require "undies/partial"

class Undies::Partial

  class BasicTest < Test::Unit::TestCase
    include TestBelt

    context 'partial'
    subject { Undies::Partial.new 'test/templates/index.html.rb' }
    should have_readers :name, :locals

    should "be a kind of Template" do
      assert subject.kind_of?(Undies::Template)
    end

  end

  class NameTest < BasicTest

    should "know its name given a file" do
      partial = Undies::Partial.new('test/templates/current.html.rb')
      assert_equal 'current', partial.name
    end

    should "know its name given a file name with a leading char" do
      partial = Undies::Partial.new('test/templates/_partial.html.rb')
      assert_equal 'partial', partial.name
    end

    should "know its name given a file name with multiple leading chars" do
      partial = Undies::Partial.new('test/templates/__partial.html.rb')
      assert_equal 'partial', partial.name
    end

  end

  class LocalsTest < BasicTest
    before do
      @path = 'test/templates/index.html.rb'
    end

    should "not have any locals by default" do
      partial = Undies::Partial.new(@path)
      assert_equal({}, partial.locals)
    end

    should "know its locals" do
      partial = Undies::Partial.new(@path, :name => 'A Name')
      assert_equal({:name => "A Name"}, partial.locals)
    end

    should "complain when locals not given as a hash" do
      assert_raises ArgumentError do
        Undies::Partial.new(@path, nil, "A Name")
      end
    end

    should "set its locals to its object" do
      partial = Undies::Partial.new(@path, "thing")
      assert_equal({:index => "thing"}, partial.locals)
    end

    should "merge its object into the locals" do
      partial = Undies::Partial.new(@path, "thing", :color => "#FFF")
      assert_equal({:index => "thing", :color => "#FFF"}, partial.locals)
    end

    should "overwrite its object with the locals if needed" do
      partial = Undies::Partial.new(@path, "thing", :index => "#FFF")
      assert_equal({:index => "#FFF"}, partial.locals)
    end

  end

end
