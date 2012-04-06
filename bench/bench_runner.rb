require 'whysoslow'

require 'erb'
require 'erubis'
require 'haml'
require 'markaby'
require 'erector'
require 'undies'

class UndiesBenchResults

  attr_accessor :name, :ext, :size

  def initialize(name, ext, size, build)
    @name = name.to_s
    @ext = ext.to_s
    @size = size.to_s
    @build = build

    @printer = Whysoslow::DefaultPrinter.new({
      :title => "#{@name}, #{@size}",
      :verbose => true
    })
    @runner = Whysoslow::Runner.new(@printer)
  end

  def file
    File.expand_path("bench/#{@size}.html#{@ext}")
  end

  def run
    @runner.run &@build
  end

end



class UndiesResults < UndiesBenchResults

  def initialize(size='large')
    super(:undies, '.rb', size, Proc.new do
      Undies::Template.new(
        Undies::Source.new(self.file),
        {},
        Undies::IO.new(@out = "", :pp => 2)
      )
    end)
  end

end

class MarkabyResults < UndiesBenchResults

  BUILDS = {}

  BUILDS['small'] = Proc.new do
    head {}
    body do
      1.times do
        5.times do
          span.awesome "Yo"
        end
        5.times do
          span.cool "YoYo"
        end
        5.times do
          br
        end
        5.times do
          div.last "Hi"
        end
      end
    end
  end

  BUILDS['large'] = Proc.new do
    head {}
    body do
      100.times do
        5.times do
          span.awesome "Yo"
        end
        5.times do
          span.cool "YoYo"
        end
        5.times do
          br
        end
        5.times do
          div.last "Hi"
        end
      end
    end
  end

  BUILDS['verylarge'] = Proc.new do
    head {}
    body do
      1000.times do
        5.times do
          span.awesome "Yo"
        end
        5.times do
          span.cool "YoYo"
        end
        5.times do
          br
        end
        5.times do
          div.last do
            span "hi"
          end
        end
      end
    end
  end

  def initialize(size='large')
    @out = ""
    super(:markaby, '.mab', size, Proc.new do
      mab = Markaby::Builder.new
      mab.html &BUILDS[size.to_s]
      @out = mab.to_s
    end)
  end

end

class ErectorResults < UndiesBenchResults

  class Build < Erector::Widget
    def content
      head {}
      body do
        @num.times do
          5.times do
            span("Yo", :class => 'awesome')
          end
          5.times do
            span("YoYo", :class => 'cool')
          end
          5.times do
            br
          end
          5.times do
            div(:class => 'last') do
              span "Hi"
            end
          end
        end
      end
    end
  end

  BUILDS = {}

  BUILDS['small'] = Build.new(:num => 1)
  BUILDS['large'] = Build.new(:num => 100)
  BUILDS['verylarge'] = Build.new(:num => 1000)

  def initialize(size='large')
    @out = ""
    super(:erector, '.erc', size, Proc.new do
      @out = BUILDS[size.to_s].to_html(:prettyprint => true)
    end)
  end

end

class HamlResults < UndiesBenchResults

  def initialize(size='large')
    @out = ""
    super(:haml, '.haml', size, Proc.new do
      @out = ::Haml::Engine.new(File.read(self.file)).to_html
    end)
  end

end

class ErbResults < UndiesBenchResults

  def initialize(size='large')
    @out = ""
    super(:erb, '.erb', size, Proc.new do
      @out = ERB.new(File.read(self.file), 0, "%<>").result(binding)
    end)
  end

end

class ErubisResults < UndiesBenchResults

  def initialize(size='large')
    @out = ""
    super(:erubis, '.erb', size, Proc.new do
      @out = Erubis::Eruby.new(File.read(self.file)).result(binding)
    end)
  end

end



class UndiesBenchRunner

  SIZES = [
    # [:small    , "~20 nodes"],
    # [:large    , "~2000 nodes"],
    [:verylarge, "~20000 nodes"]
  ]


  def initialize
    puts "Benchmark Results:"
    puts
    SIZES.each do |size_desc|
      UndiesResults.new(size_desc.first).run
      puts
      ErectorResults.new(size_desc.first).run
      puts
      # MarkabyResults.new(size_desc.first).run
      # puts
      # HamlResults.new(size_desc.first).run
      # puts
      # ErbResults.new(size_desc.first).run
      # puts
      # ErubisResults.new(size_desc.first).run
      # puts
    end
    puts
  end

end
