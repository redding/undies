require "assert"

require "undies/output"
require "undies/node"

class Undies::Node

  class BasicTests < Assert::Context
    desc 'a node'
    before do
      skip
      @output = Undies::Output.new(StringIO.new(@out = ""))
      @n = Undies::Node.new("a text node here")
    end
    subject { @n }

    should have_instance_methods :__start_tag, :__end_tag, :__set_start_tag, :__set_end_tag
    should have_instance_methods :__builds,   :__add_build
    should have_instance_methods :__children, :__set_children
    should have_instance_methods :__attrs,    :__merge_attrs
    should have_instance_methods :__node_name, :__content, :__mode, :__prefix

    should "have no start/end tags" do
      assert_empty subject.__start_tag
      assert_empty subject.__end_tag
    end

    should "have content" do
      assert_equal "a text node here", subject.__content
    end

    should "have no builds" do
      assert_empty subject.__builds
    end

    should "be :inline mode by default" do
      assert_equal :inline, subject.__mode
    end

    should "have no prefix if :inline mode" do
      assert_empty subject.__prefix('start_tag', 2, 2)
      assert_empty subject.__prefix('end_tag', 1, 2)
    end

    should "have a pp prefix if not :inline mode" do
      node = Undies::Node.new("a non inline node", :partial)
      assert_equal "\n    ", node.__prefix('start_tag', 2, 2)
      assert_equal "\n  ",   node.__prefix('end_tag', 2, 2)
      assert_equal "\n  ",   node.__prefix('start_tag', 1, 2)
      assert_equal "\n",     node.__prefix('end_tag', 1, 2)
      assert_equal "",       node.__prefix('start_tag', 0, 2)
      assert_equal "\n",     node.__prefix('end_tag', 0, 2)
    end

    should "have no children by default" do
      assert_equal false, subject.__children
    end

    should "have no attrs by default" do
      assert_empty subject.__attrs
    end

    should "have no name by default" do
      assert_empty subject.__node_name
    end

    should "add a build if given a block" do
      subject.__add_build(Proc.new {})
      assert_equal [Proc.new {}], subject.__builds

      subject.__add_build(Proc.new {})
      assert_equal [Proc.new {}, Proc.new {}], subject.__builds
    end

    should "set children if given a value" do
      subject.__set_children(true)
      assert_equal true, subject.__children
    end

    should "merge attrs if given an attrs hash" do
      attrs_hash = {:same => 'value', :new => 'a new value'}
      subject.__merge_attrs(attrs_hash)
      assert_equal attrs_hash, subject.__attrs

      attrs_hash = {:same => 'new same', :new => 'a new value'}
      subject.__merge_attrs(attrs_hash)
      assert_equal attrs_hash, subject.__attrs
    end

  end

end
