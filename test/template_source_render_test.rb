require "assert"
require "undies/template"

class Undies::Template



  class SourceRenderTests < Assert::Context
    desc 'a template rendered using a source object'
    before do
      @src = Undies::Source.new(Proc.new {})
      @io = Undies::IO.new(@out = "")
      @t = Undies::Template.new(@src, {}, @io)
    end
    subject { @t }

    should "maintain the template's scope throughout the build blocks" do
      templ = Undies::Template.new(Undies::Source.new do
        _div {
          _div {
            __ self.object_id
          }
        }
      end, {}, @io)
      assert_equal "<div><div>#{templ.object_id}</div></div>", @out
    end

  end



  class LayoutTests < SourceRenderTests
    setup do
      @expected_output = "<html><head></head><body><div>Hi</div></body></html>"

      @layout_proc = Proc.new do
        _html {
          _head {}
          _body {
            __yield
          }
        }
      end
      @layout_file = File.expand_path "test/templates/layout.html.rb"

      @content_proc = Proc.new do
        _div { _ "Hi" }
      end
      @content_file = File.expand_path "test/templates/content.html.rb"

      @cp_lp_source = Undies::Source.new(:layout => @layout_proc, &@content_proc)
      @cp_lf_source = Undies::Source.new(:layout => @layout_file, &@content_proc)
      @cf_lp_source = Undies::Source.new(@content_file, :layout => @layout_proc)
      @cf_lf_source = Undies::Source.new(@content_file, :layout => @layout_file)
    end

    should "generate markup given proc content in a proc layout" do
      Undies::Template.new(@cp_lp_source, {}, @io)
      assert_equal @expected_output, @out
    end

    should "generate markup given proc content in a layout file" do
      Undies::Template.new(@cp_lf_source, {}, @io)
      assert_equal @expected_output, @out
    end

    should "generate markup given a content file in a proc layout" do
      Undies::Template.new(@cf_lp_source, {}, @io)
      assert_equal @expected_output, @out
    end

    should "generate markup given a content file in a layout file" do
      Undies::Template.new(@cf_lf_source, {}, @io)
      assert_equal @expected_output, @out
    end

  end



  class PartialTests < SourceRenderTests
    desc "using partials"

    before do
      @io = Undies::IO.new(@out = "", :pp => 2)
      @source = Undies::Source.new(Proc.new do
        partial_source = Undies::Source.new(Proc.new do
          _p { _ thing }
        end)

        _div {
          _span { _ thing }
          __partial partial_source, {:thing => 1234}

          _div {
            __partial "    <p>some markup string here</p>\n"
          }

        }
      end)
      @data = {:thing => 'abcd'}
    end

    should "render the partial source with its own scope/data" do
      Undies::Template.new(@source, @data, @io)
      assert_equal "<div>\n  <span>abcd</span>\n  <p>1234</p>\n  <div>\n    <p>some markup string here</p>\n  </div>\n</div>\n", @out
    end

  end



end
