require "assert"

require "undies/node"

class Undies::Node

  class BasicTests < Assert::Context
    desc 'a node'
    before { @n = Undies::Node.new("a text node here") }
    subject { @n }

    should have_instance_method :to_s
    should have_class_methods :content, :start_tag, :end_tag

    should "know it's content" do
      assert_equal "a text node here", subject.class.content(subject).to_s
    end

    should "know how to serialize itself" do
      assert_equal "a text node here", subject.to_s
    end

  end

end
