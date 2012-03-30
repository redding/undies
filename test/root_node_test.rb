require "assert"
require 'undies/io'
require 'undies/element'
require "undies/root_node"

class Undies::RootNode

  class BasicTests < Assert::Context
    desc 'a root node'
    before do
      @io = Undies::IO.new(@out = "", :pp => 1)
      @n = Undies::RootNode.new(@io)
    end
    subject { @n }

    should have_instance_methods :__attrs, :__flush, :__push, :__pop
    should have_instance_methods :__markup, :__element, :__partial
    should have_instance_methods :__cached, :__builds

    should "have no builds" do
      assert_empty subject.__builds
    end

    should "have nothing cached by default" do
      assert_nil subject.__cached
    end

    should "cache any raw markup given" do
      subject.__markup "some raw markup"
      assert_equal "some raw markup#{@io.newline}", subject.__cached
    end

    should "write out any cached value when new markup is given" do
      subject.__markup "some raw markup"
      assert_empty @out

      subject.__markup "more raw markup"
      assert_equal "some raw markup\n", @out
    end

    should "cache any element given" do
      subject.__element(elem = Undies::Element.new(@io, :br))
      assert_equal elem, subject.__cached
    end

    should "return the element when given" do
      elem = Undies::Element.new(@io, :br)
      assert_equal elem, subject.__element(elem)
    end

    should "write out any cached value when a new element is given" do
      subject.__element(elem = Undies::Element.new(@io, :br))
      assert_empty @out

      subject.__element(elem = Undies::Element.new(@io, :strong))
      assert_equal "<br />#{@io.newline}", @out
    end

    should "cache any partial markup given" do
      subject.__partial "some partial markup"
      assert_equal "some partial markup#{@io.newline}", subject.__cached
    end

    should "write out any cached value when new partial markup is given" do
      subject.__partial "some partial markup"
      assert_empty @out

      subject.__partial "more partial markup"
      assert_equal "some partial markup\n", @out
    end

    should "write out any cached value when flushed" do
      subject.__flush
      assert_empty @out

      subject.__markup "some raw markup"
      subject.__flush
      assert_equal "some raw markup\n", @out
    end

    should "only flush if popped" do
      io_level = @io.level
      subject.__markup "some raw markup"
      subject.__pop
      assert_equal "some raw markup\n", @out
      assert_equal io_level, @io.level
    end

    should "push the cached content to the IO handler" do
      io_level = @io.level
      subject.__markup "some raw markup"
      subject.__push
      assert_equal io_level+1, @io.level
      assert_equal "some raw markup#{@io.newline}", @io.current
    end

  end

end
