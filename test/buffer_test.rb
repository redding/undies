require "test/helper"
require "undies/buffer"
require "undies/tag"

class Undies::Buffer




  class BasicTest < Test::Unit::TestCase
    include TestBelt

    context 'a buffer'
    subject { Undies::Buffer.new }
    should have_instance_methods :to_s, :_, :__, :tag

    should "be a kind of ::Array" do
      assert subject.kind_of?(::Array)
    end

  end



  class DataTest < BasicTest
    context "with data"
    before do
      @data = "stuff & <em>more stuff</em>"
    end

    should "add it un-escaped using the '__' method" do
      subject.__ @data
      assert_equal "stuff & <em>more stuff</em>", subject.to_s
    end

    should "add it escaped using the '_' method" do
      subject._ @data
      assert_equal "stuff &amp; &lt;em&gt;more stuff&lt;&#x2F;em&gt;", subject.to_s
    end

  end



  class TagTest < BasicTest
    context "when using the tag method"

    should "add a new Tag object" do
      subject.tag(:br)
      assert_equal Undies::Tag.new(:br), subject.first
    end

    should "respond to any underscore prefix method" do
      assert subject.respond_to?(:_div)
    end

    should "not respond to tag methods without an underscore prefix" do
      assert !subject.respond_to?(:div)
      assert_raises NoMethodError do
        subject.div
      end
    end

    should "interpret underscore prefix methods as a tag" do
      assert_equal subject._div, subject.tag(:div)
    end

  end



  # TODO: pretty printing


end
