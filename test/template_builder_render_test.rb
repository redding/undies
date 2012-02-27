require "assert"
require "stringio"
require 'undies/node_stack'

require "undies/template"

class Undies::Template

  class BuilderRenderTests < Assert::Context
    desc 'a template rendered using the builder approach'
    before do
      @src = Undies::Source.new(Proc.new {})
      @output = Undies::Output.new(@outstream = StringIO.new(@out = ""))
      @t = Undies::Template.new(@src, {}, @output)
    end
    subject { @t }

    should "maintain scope throughout the build blocks" do
      templ = Undies::Template.new(@output)
      templ._div {
        templ._div {
          templ.__ self.object_id
        }
      }
      templ.__flush

      assert_equal "<div><div>#{self.object_id}</div></div>", @out
    end

  end

end
