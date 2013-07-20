require "assert"
require "undies/template"

class Undies::Template

  class BuilderRenderTests < Assert::Context
    desc 'a template rendered using the builder approach'
    before do
      @src = Undies::Source.new(Proc.new {})
      @io = Undies::IO.new(@out = "")
      @t = Undies::Template.new(@src, {}, @io)
    end
    subject { @t }

    should "maintain scope throughout the build blocks" do
      templ = Undies::Template.new(@io)
      templ._div {
        templ._div self.object_id
      }
      templ.__flush

      assert_equal "<div><div>#{self.object_id}</div></div>", @out
    end

  end

end
