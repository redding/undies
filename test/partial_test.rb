require "test/helper"
require "undies/partial"

class Undies::Partial

  class BasicTest < Test::Unit::TestCase
    include TestBelt

    context 'partial'
    subject { Undies::Partial.new 'index.html.rb' }
    should have_readers :name, :path, :locals

    should "be a kind of Template" do
      assert subject.kind_of?(Undies::Template)
    end

  end

  class NameTest < BasicTest
    before { skip }

    should "know its name given a file in the current dir" do
      assert_equal 'current', Undies::Partial.new('current.html.rb')
    end

    should "know its name given a file name with leading _" do
      assert_equal 'partial', Undies::Partial.new('_partial.html.rb')
    end

    should "know its name given a file explicitly in the current dir" do
      assert_equal 'xcurrent', Undies::Partial.new('./explicit.html.rb')
    end

    should "know its name given a file nested in the current dir" do
      assert_equal 'nested', Undies::Partial.new('something/_nested.html.rb')
    end

    should "know its name given an absolute file path" do
      assert_equal 'absolute', Undies::Partial.new('/something/absolute.html.rb')
    end

  end

  class LocalsTest < BasicTest
    before { skip }

    should "not have any locals by default" do
    end

    should "know its locals" do
    end

    should "complain when locals not given as a hash" do
    end

    should "set its locals to its object" do
    end

    should "merge its object into the locals" do
    end

  end

end
