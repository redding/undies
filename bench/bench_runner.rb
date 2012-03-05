require 'whysoslow'
require 'stringio'

require 'erb'
require 'erubis'
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
    @outstream = StringIO.new(@out = "")
    super(:undies, '.rb', size, Proc.new do
      Undies::Template.new(
        Undies::Source.new(self.file),
        {},
        Undies::Output.new(@outstream, :pp => 2)
      )
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

  SIZES = {
    # :small     => "~20 nodes",
    # :large     => "~2000 nodes",
    :verylarge => "~20000 nodes"
  }


  def initialize
    puts "Benchmark Results:"
    puts
    SIZES.each do |size, desc|
      ErbResults.new(size).run
      puts
      ErubisResults.new(size).run
      puts
      UndiesResults.new(size).run
      puts
    end
    puts
  end

end
