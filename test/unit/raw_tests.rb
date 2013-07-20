require 'assert'
require 'undies/template'
require 'undies/element'

module Undies

  class RawTests < Assert::Context
    desc 'the Raw class'
    before do
      @rs = Raw.new "ab&<>'\"/yz"
    end
    subject { @rs }

    should "be a String" do
      assert_kind_of ::String, subject
    end

    should "ignore any gsubbing" do
      assert_equal subject.to_s, subject.gsub('ab', '__').gsub('yz', '--')
      assert_equal subject.to_s, Template.escape_html(subject)
    end

  end

end
