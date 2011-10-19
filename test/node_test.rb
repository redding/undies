require "assert"

require "undies/node"

class Undies::Node

  class BasicTests < Assert::Context
    desc 'a node'
    before { @n = Undies::Node.new("a text node here") }
    subject { @n }
    should have_instance_methods :to_s, :___content___
    should have_instance_methods :___start_tag___, :___end_tag___

    should "know it's content" do
      assert_equal "a text node here", subject.___content___.to_s
    end

    should "know how to serialize itself" do
      assert_equal "a text node here", subject.to_s
    end

  end

end
