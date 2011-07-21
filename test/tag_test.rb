require "test/helper"
require "undies/tag"

class Undies::Tag



  class BasicTest < Test::Unit::TestCase
    include TestBelt

    context 'a tag'
    subject { Undies::Tag.new(:div) }
    should have_instance_methods :to_s
  end



  class HtmlAttrsTest < BasicTest
    context "html_attrs util"

    should "convert an empty hash to html attrs" do
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



  class SerializeTest < BasicTest
    context "when serialized"

    should "buffer an empty html tag with no attrs" do
      tag = Undies::Tag.new(:br)
      assert_equal "<br />", tag.to_s
    end

    should "buffer an html tag with attrs" do
      tag = Undies::Tag.new(:br, {:class => 'big'})
      assert_equal '<br class="big" />', tag.to_s
    end

    should "buffer an html tag with attrs and content" do
      tag = Undies::Tag.new(:strong, {:class => 'big'}) { __ "Loud Noises!" }
      assert_equal '<strong class="big">Loud Noises!</strong>', tag.to_s
    end
  end

end
