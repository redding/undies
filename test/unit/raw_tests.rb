require 'assert'
require 'undies/raw'

require 'undies/template'

class Undies::Raw

  class UnitTests < Assert::Context
    desc 'the Raw class'
    before do
      @rs = Undies::Raw.new "ab&<>'\"/yz"
    end
    subject { @rs }

    should "be a String" do
      assert_kind_of ::String, subject
    end

    should "ignore any gsubbing" do
      assert_equal subject.to_s, subject.gsub('ab', '__').gsub('yz', '--')
      assert_equal subject.to_s, Undies::Template.escape_html(subject)
    end

  end

end
