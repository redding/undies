require "test/helper"
require "undies/buffer"

class Undies::Buffer

  class BufferTest < Test::Unit::TestCase
    include TestBelt

    context 'a buffer'
    subject { Undies::Buffer.new }
    should have_instance_methods :to_s

    should "be a kind of ::Array" do
      assert subject.kind_of?(::Array)
    end
  end

end
