require "assert"
require 'undies/io'
require 'undies/element_node'
require 'undies/element'
require "undies/root_node"

class Undies::RootNode

  class BasicTests < Assert::Context
    desc 'a root node'
    before do
      @io = Undies::IO.new(@out = "", :pp => 1)
      @rn = Undies::RootNode.new(@io)

      @e  = Undies::Element::Closed.new(:br)
      @en = Undies::ElementNode.new(@io, @e)
    end
    subject { @rn }

    should have_readers :io, :cached
    should have_instance_methods :attrs, :text, :element_node
    should have_instance_methods :partial, :flush, :push, :pop

    should "know its IO" do
      assert_equal @io, subject.io
    end

    should "have nothing cached by default" do
      assert_nil subject.cached
    end

    should "complain if trying to specify attrs" do
      assert_raises Undies::RootAPIError do
        subject.attrs({:blah => 'whatever'})
      end
    end

    should "cache any raw text given" do
      subject.text "some raw markup"
      assert_equal "some raw markup#{@io.newline}", subject.cached
    end

    should "write out any cached value when new markup is given" do
      subject.text "some raw markup"
      assert_empty @out

      subject.text "more raw markup"
      assert_equal "some raw markup\n", @out
    end

    should "cache any element node given" do
      subject.element_node(@en)
      assert_equal @en, subject.cached
    end

    should "return the element when given" do
      assert_equal @en, subject.element_node(@en)
    end

    should "write out any cached value when a new element is given" do
      subject.element_node(@en)
      assert_empty @out

      subject.element_node(@en)
      assert_equal "<br />#{@io.newline}", @out
    end

    should "cache any partial markup given" do
      subject.partial "some partial markup"
      assert_equal "some partial markup#{@io.newline}", subject.cached
    end

    should "write out any cached value when new partial markup is given" do
      subject.partial "some partial markup"
      assert_empty @out

      subject.partial "more partial markup"
      assert_equal "some partial markup\n", @out
    end

    should "write out any cached value when flushed" do
      subject.flush
      assert_empty @out

      subject.text "some raw markup"
      subject.flush
      assert_equal "some raw markup\n", @out
    end

    should "only flush if popped" do
      io_level = @io.level
      subject.text "some raw markup"
      subject.pop
      assert_equal "some raw markup\n", @out
      assert_equal io_level, @io.level
    end

    should "push the cached content to the IO handler" do
      io_level = @io.level
      subject.text "some raw markup"
      subject.push
      assert_equal io_level+1, @io.level
      assert_equal "some raw markup#{@io.newline}", @io.current
    end

  end

end
