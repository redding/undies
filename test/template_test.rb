require "test/helper"

class Undies::Template

  class TemplateTest < Test::Unit::TestCase
    include TestBelt

    context 'a template'
    subject { Undies::Template.new {} }
    should have_instance_methods :__, :tag, :to_s
  end

  class BufferTest < TemplateTest
    context "buffer methods"

    should "un-escaped buffer whatever is passed to it" do
      subject.__ "stuff"
      assert_equal "stuff", subject.buffer.to_s
    end

    should "be aliased as the '__' method to less obtrusive in templates" do
      subject.__ "stuffblah\nblah\nblah"
      assert_equal "stuffblah\nblah\nblah", subject.buffer.to_s
    end
  end

  class HtmlAttrsTest < TemplateTest
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

  class TagTest < TemplateTest
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
  end

  class TagMethodsTest < TemplateTest
    should "should respond to tag methods with an underscore prefix" do
      assert subject.respond_to?(:_div)
    end

    should "not respond to tag methods without an underscore prefix" do
      assert !subject.respond_to?(:div)
      assert_raises NoMethodError do
        subject.div
      end
    end

    should "generate tag markup" do
      subject._div {}
      assert_equal "<div></div>", subject.buffer.to_s
    end
  end

  class DefinitionTest < TemplateTest
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
