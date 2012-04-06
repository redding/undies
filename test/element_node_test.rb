require "assert"
require 'undies/io'
require 'undies/element_node'
require 'undies/element'


class Undies::ElementNode

  class BasicTests < Assert::Context
    desc 'an element node'
    before do
      # io test with :pp 1 so we can test newline insertion
      # io test with level 1 so we can test element start tag writing
      @io = Undies::IO.new(@out = "", :pp => 1, :level => 1)
      @e  = Undies::Element.open(:div, "hi")
      @en = Undies::ElementNode.new(@io, @e)
    end
    subject { @en }

    should have_readers :io, :element, :cached
    should have_instance_methods :attrs, :text, :element_node
    should have_instance_methods :partial, :flush, :push, :pop, :to_s

    should "know its IO" do
      assert_equal @io, subject.io
    end

    should "know its element" do
      assert_equal @e, subject.element
    end

    should "have nothing cached by default" do
      assert_nil subject.cached
    end

    should "complain if trying to add text in a build" do
      assert_raises Undies::ElementAPIError do
        subject.text 'blah'
      end
    end

  end



  class AddContentTests < BasicTests
    desc "adding content"
    before do
      @text1 = "some raw markup"
      @text2 = "more raw markup"
      @elem1 = Undies::Element::Open.new(:strong, "blah")
      @elem2 = Undies::Element::Closed.new(:br).meh
      @en1   = Undies::ElementNode.new(@io, @elem1)
      @en2   = Undies::ElementNode.new(@io, @elem2)
    end

  end

  class AddContentStartTagWrittenTests < AddContentTests
    desc "(the start tag has already been written)"
    before do
      subject.instance_variable_set("@start_tag_written", true)
    end

  end

  class ElementStartTagWrittenTests < AddContentStartTagWrittenTests
    desc "using the element_node meth"

    should "cache any element node given" do
      subject.element_node(@en1)
      assert_equal @en1, subject.cached
    end

    should "return the element node" do
      assert_equal @en1, subject.element_node(@en1)
    end

    should "write out any cached value when a new element is given" do
      subject.element_node(@en1)
      assert_empty @out

      subject.element_node(@en2)
      assert_equal "#{@io.line_indent}<strong>blah</strong>#{@io.newline}", @out
    end

    should "write out any cached value when flushed" do
      subject.flush
      assert_empty @out

      subject.element_node(@en1)
      subject.flush
      assert_equal "#{@io.line_indent}<strong>blah</strong>#{@io.newline}", @out
    end

  end

  class PartialStartTagWrittenTests < AddContentStartTagWrittenTests
    desc "using the partial meth"

    should "cache any partial markup given" do
      subject.partial("partial markup")
      assert_equal "partial markup", subject.cached
    end

    should "write out any cached partial values" do
      subject.partial("partial markup")
      assert_empty @out

      subject.element_node(@en2)
      assert_equal "partial markup", @out
    end

    should "write out any cached value when flushed" do
      subject.flush
      assert_empty @out

      subject.partial("partial markup")
      subject.flush
      assert_equal "partial markup", @out
    end

  end



  class AddContentStartTagNotWrittenTests < AddContentTests
    desc "(the start tag has not been written)"
    before do
      subject.instance_variable_set("@start_tag_written", false)
    end

  end

  class ElementStartTagNotWrittenTests < AddContentStartTagNotWrittenTests
    desc "using the element_node meth"

    should "cache any element_node given" do
      subject.element_node(@en1)
      assert_equal @en1, subject.cached
    end

    should "return the element node" do
      assert_equal @en1, subject.element_node(@en1)
    end

    should "write out the start tag with IO#newline when an element is given" do
      subject.element_node(@en1)
      assert_equal "<div>#{@io.newline}", @out
    end

    should "write out any cached content and cache new markup when given" do
      subject.element_node @en1
      subject.element_node @en2
      assert_equal "<div>#{@io.newline}#{@io.line_indent}<strong>blah</strong>#{@io.newline}", @out
      assert_equal @en2, subject.cached
    end

    should "write out the end tag with IO#newline indented when popped" do
      subject.element_node(@en1)
      subject.pop
      assert_equal "<div>#{@io.newline} <strong>blah</strong>#{@io.newline}</div>#{@io.newline}", @out
    end

  end

  class PartialStartTagNotWrittenTests < AddContentStartTagNotWrittenTests
    desc "using the partial meth"

    should "cache any partial markup given" do
      subject.partial("partial markup")
      assert_equal "partial markup", subject.cached
    end

    should "write out the start tag with IO#newline when a partial is given" do
      subject.partial("partial markup")
      assert_equal "<div>#{@io.newline}", @out
    end

    should "write out the end tag with IO#newline indented when a partial is given" do
      subject.partial("  partial markup\n")
      subject.pop
      assert_equal "<div>#{@io.newline}  partial markup\n</div>#{@io.newline}", @out
    end

  end

  class AttrsTests < AddContentStartTagNotWrittenTests
    desc "using the attrs meth"

    should "modify the parent element's tag attributes" do
      subject.attrs(:test => 'value')
      subject.element_node(@en1)

      assert_equal "<div test=\"value\">#{@io.newline}", @out
    end

    should "not effect the start tag once child elements have been written" do
      subject.attrs(:test => 'value')
      subject.element_node(@en1)
      subject.attrs(:another => 'val')

      assert_equal "<div test=\"value\">#{@io.newline}", @out
    end

  end



  class SerializeTests < BasicTests

    should "serialize nested elements with pp and only honor the last build block" do
      io = Undies::IO.new(@out = "", :pp => 1, :level => 0)

      e1a  = Undies::Element::Open.new :span, 'Content!'
      en1a = Undies::ElementNode.new(io, e1a)

      e1b  = Undies::Element::Open.new :span, 'More content'
      en1b = Undies::ElementNode.new(io, e1b)

      e1c  = Undies::Element::Open.new :div
      en1c = Undies::ElementNode.new(io, e1c)

      e2a  = Undies::Element::Open.new :p, 'a'
      en2a = Undies::ElementNode.new(io, e2a)

      e2b  = Undies::Element::Open.new :p, 'b'
      en2b = Undies::ElementNode.new(io, e2b)

      e_root  = Undies::Element::Open.new :div
      en_root = Undies::ElementNode.new(io, e_root)
      e_root.test do
        en_root.attrs :class => 'root'
        en_root.element_node(en1a)
        en_root.element_node(en1b)
        en_root.element_node(en1c)
      end

      # any build trumps any content provided in the args
      e1b.test {
        en1b.element_node(en2a)
      }

      # the last build specified is the only one used
      e1c.
        proxy {
          # this will be ignored
          en1c.element_node(en1a)
        }.
        start_tag.
        you! {
          # this will be the build for e1c
          # only builds on the last proxy call
          en1c.element_node(en2b)
        }


      en_root.to_s

      assert_equal "<div class=\"root\">
 <span>Content!</span>
 <span class=\"test\">
  <p>a</p>
 </span>
 <div class=\"proxy start_tag\" id=\"you\">
  <p>b</p>
 </div>
</div>
", @out
    end

  end

end
