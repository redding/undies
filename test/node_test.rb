require "assert"

require "undies/output"
require "undies/node"

class Undies::Node

  class BasicTests < Assert::Context
    desc 'a node'
    before do
      @output = Undies::Output.new(StringIO.new(@out = ""))
      @n = Undies::Node.new("a text node here")
    end
    subject { @n }

    should have_class_methods :start_tag, :end_tag, :set_start_tag, :set_end_tag
    should have_class_methods :node_name, :content, :builds, :mode, :prefix
    should have_class_methods :attrs, :set_attrs
    should have_class_methods :children, :set_children

    should "have no start/end tags" do
      assert_empty subject.class.start_tag(subject)
      assert_empty subject.class.end_tag(subject)
    end

    should "have content" do
      assert_equal "a text node here", subject.class.content(subject)
    end

    should "have no builds" do
      assert_empty subject.class.builds(subject)
    end

    should "be :inline mode by default" do
      assert_equal :inline, subject.class.mode(subject)
    end

    should "have no prefix if :inline mode" do
      assert_empty subject.class.prefix(subject, 'start_tag', 2, 2)
      assert_empty subject.class.prefix(subject, 'end_tag', 1, 2)
    end

    should "have a pp prefix if not :inline mode" do
      node = Undies::Node.new("a non inline node", :partial)
      assert_equal "\n    ", node.class.prefix(node, 'start_tag', 2, 2)
      assert_equal "\n  ",   node.class.prefix(node, 'end_tag', 2, 2)
      assert_equal "\n  ",   node.class.prefix(node, 'start_tag', 1, 2)
      assert_equal "\n",     node.class.prefix(node, 'end_tag', 1, 2)
      assert_equal "",       node.class.prefix(node, 'start_tag', 0, 2)
      assert_equal "\n",     node.class.prefix(node, 'end_tag', 0, 2)
    end

    should "have no children by default" do
      assert_equal false, subject.class.children(subject)
    end

    should "have no attrs by default" do
      assert_empty subject.class.attrs(subject)
    end

    should "have no name by default" do
      assert_empty subject.class.node_name(subject)
    end

    should "set children if given a value" do
      subject.class.set_children(subject, true)
      assert_equal true, subject.class.children(subject)
    end

    should "merge attrs if given an attrs hash" do
      attrs_hash = {:same => 'value', :new => 'a new value'}
      subject.class.set_attrs(subject, attrs_hash)
      assert_equal attrs_hash, subject.class.attrs(subject)

      attrs_hash = {:same => 'new same', :new => 'a new value'}
      subject.class.set_attrs(subject, attrs_hash)
      assert_equal attrs_hash, subject.class.attrs(subject)
    end

  end

end
