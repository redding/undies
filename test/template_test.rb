require "test/helper"

class Undies::Template

  class BasicTest < Test::Unit::TestCase
    include TestBelt

    context 'template'
    subject { Undies::Template.new {} }
    should have_instance_methods :to_s, :tag, :_, :__
  end

  class BufferContentTest < BasicTest
    context "with raw content"
    before do
      @content = "stuff & <em>more stuff</em>"
    end

    should "buffer it un-escaped using the '__' method" do
      subject.__ @content
      assert_equal "stuff & <em>more stuff</em>", subject.buffer.to_s
    end

    should "buffer it escaped using the '_' method" do
      subject._ @content
      assert_equal "stuff &amp; &lt;em&gt;more stuff&lt;&#x2F;em&gt;", subject.buffer.to_s
    end

  end

  class HtmlAttrsTest < BasicTest
    context "html_attrs util"

    should "convert an empty hash to html attrs" do
      @expected = ""
      assert_equal('', subject.send(:html_attrs, {}))
    end

    should "convert a basic hash to html attrs" do
      attrs = subject.send(:html_attrs, :class => "test", :id => "test_1")
      assert_match /^\s{1}/, attrs
      assert attrs.include?('class="test"')
      assert attrs.include?('id="test_1"')
    end

    should "convert a nested hash to html attrs" do
      attrs = subject.send(:html_attrs, {
        :class => "testing", :id => "test_2",
        :nested => {:something => 'is_awesome'}
      })
      assert_match /^\s{1}/, attrs
      assert attrs.include?('class="testing"')
      assert attrs.include?('id="test_2"')
      assert attrs.include?('nested="somethingis_awesome"')
    end
  end

  class TagTest < BasicTest
    context "tag method"

    should "buffer an empty html tag with no attrs" do
      subject.tag(:br)
      assert_equal "<br />", subject.buffer.to_s
    end

    should "buffer an html tag with attrs" do
      subject.tag(:br, {:class => 'big'})
      assert_equal '<br class="big" />', subject.buffer.to_s
    end

    should "buffer an html tag with attrs and content" do
      subject.tag(:strong, {:class => 'big'}) { subject.__ "Loud Noises!" }
      assert_equal '<strong class="big">Loud Noises!</strong>', subject.buffer.to_s
    end

    should "respond to any underscore prefix method" do
      assert subject.respond_to?(:_h1)
      assert subject.respond_to?(:_div)
    end

    should "not respond to tag methods without an underscore prefix" do
      assert !subject.respond_to?(:div)
      assert_raises NoMethodError do
        subject.div
      end
    end

    should "interpret underscore prefix methods as a tag" do
      assert_equal subject._br, subject.tag(:br)
      assert_equal subject._div(:class => 'big'), subject.tag(:div, :class => 'big')
    end
  end

  class DefinitionTest < BasicTest
    should "generate markup given a block" do
      assert_equal(
        "<html><head></head><body><div class=\"yea\">YEA!!</div></body></html>",
        Undies::Template.new do
          _html {
            _head {}
            _body {
              _div('.yea') {
                __ "YEA!!"
              }
            }
          }
        end.to_s
      )
    end

    should "generate markup given a file" do
      file = 'test/test_template.html.rb'
      assert_equal(
        "<html><head></head><body><div class=\"file\">FILE!!</div></body></html>",
        Undies::Template.new(File.expand_path(file)).to_s
      )
    end
  end

end
