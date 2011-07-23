require "test/helper"
require "undies/node_list"
require "undies/node"

class Undies::NodeList

  class BasicTest < Test::Unit::TestCase
    include TestBelt

    context 'a node list'
    subject { Undies::NodeList.new }
    should have_instance_method :append

    should "be an Array" do
      assert_kind_of ::Array, subject
    end

    should "always init empty" do
      assert_equal 0, subject.size
      assert_equal 0, Undies::NodeList.new([1,2,3]).size
    end

    should "complain if you try to append something other than a node" do
      assert_raises ArgumentError do
        subject.append('hey!')
      end
      assert_raises ArgumentError do
        subject << 'hey!'
      end
      assert_nothing_raised do
        subject.append(Undies::Node.new('hey!'))
        subject << Undies::Node.new('hey!')
      end
    end

    should "append nodes with the 'append' method" do
      subject.append(Undies::Node.new "hey!")
      assert_equal 1, subject.size
    end

    should "return the node when appending" do
      node = Undies::Node.new "hey!"
      assert_equal node.object_id, subject.append(node).object_id
    end

  end

end
