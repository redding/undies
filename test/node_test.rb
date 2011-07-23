require "test/helper"
require "undies/node"

class Undies::Node

  class BasicTest < Test::Unit::TestCase
    include TestBelt

    context 'a node'
    subject { Undies::Node.new("a text node here") }
    should have_instance_method :to_s, :start_tag, :end_tag
    should have_reader :content

    should "know it's content" do
      assert_equal "a text node here", subject.content.to_s
    end

    should "know how to serialize itself" do
      assert_equal "a text node here", subject.to_s
    end

  end

end
