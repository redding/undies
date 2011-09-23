require "test_belt"
require "undies/partial_data"

class Undies::PartialLocals

  class BasicTest < Test::Unit::TestCase
    include TestBelt

    context 'partial data'
    subject { Undies::PartialLocals.new 'test/templates/index.html.rb' }
    should have_readers :path, :name

    should "be a kind of Hash" do
      assert subject.kind_of?(::Hash)
    end

    should "complain if now path given" do
      assert_raises ArgumentError do
        Undies::PartialLocals.new
      end
    end

  end

  class NameTest < BasicTest

    should "know its name given a file" do
      data = Undies::PartialLocals.new('test/templates/current.html.rb')
      assert_equal 'current', data.name
    end

    should "know its name given a file name with a leading char" do
      data = Undies::PartialLocals.new('test/templates/_partial.html.rb')
      assert_equal 'partial', data.name
    end

    should "know its name given a file name with multiple leading chars" do
      data = Undies::PartialLocals.new('test/templates/__partial.html.rb')
      assert_equal 'partial', data.name
    end

  end

  class ValuesTest < BasicTest
    before do
      @path = 'test/templates/index.html.rb'
    end
    subject { Undies::PartialLocals.new(@path) }

    should "not have any values by default" do
      assert_equal({}, subject)
    end

    should "know its values" do
      subject.values = {:name => 'A Name'}
      assert_equal({:name => "A Name"}, subject)
    end

    should "complain when values not given as a hash" do
      assert_raises ArgumentError do
        subject.values = "some data"
      end
    end

    should "force its object value to a string key" do
      assert !subject.has_key?(:index)
      assert !subject.has_key?('index')
      subject.object = "thing"
      assert !subject.has_key?(:index)
      assert subject.has_key?('index')
    end

    should "force its name value to a string key" do
      assert !subject.has_key?(:index)
      assert !subject.has_key?('index')
      subject.values = {:index => 'thing'}
      assert !subject.has_key?(:index)
      assert subject.has_key?('index')
    end

    should "set its values to its object" do
      subject.object = "thing"
      assert_equal({'index' => "thing"}, subject)
    end

    should "merge its object into the values" do
      subject.object = "thing"
      subject.values = {:color => "#FFF"}
      assert_equal({'index' => "thing", :color => "#FFF"}, subject)
    end

    should "overwrite its object with the values if needed" do
      subject.object = "thing"
      subject.values = {'index' => "#FFF"}
      assert_equal({'index' => "#FFF"}, subject)
    end

  end

end
