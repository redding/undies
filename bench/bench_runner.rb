require 'benchmark'
require 'stringio'
require 'ansi'

require 'undies'
require 'erb'
require 'erubis'

class BenchResults

  attr_reader :user, :system, :total, :real
  attr_accessor :name, :ext, :size, :out, :outstream

  def initialize(name, ext, size)
    @name = name.to_s
    @ext = ext.to_s
    @size = size.to_s
    @user, @system, @total, @real = 0
    @outstream = StringIO.new(@out = "")
  end

  def file
    File.expand_path("bench/#{@size}.html#{@ext}")
  end

  def user=(value_in_secs);   @user   = value_in_secs.to_f * 1000; end
  def system=(value_in_secs); @system = value_in_secs.to_f * 1000; end
  def total=(value_in_secs);  @total  = value_in_secs.to_f * 1000; end
  def real=(value_in_secs);   @real   = value_in_secs.to_f * 1000; end

  def to_s(meas=:real, basis=nil)
    "#{name_s} (#{size_s}):  #{time_s(meas)} ms  #{"(#{basis_s(meas, basis)})" if basis}"
  end

  protected

  def measure(&block)
    Benchmark.measure(&block).to_s.strip.gsub(/[^\s|0-9|\.]/, '').split(/\s+/).tap do |values|
      self.user, self.system, self.total, self.real = values
    end
  end

  def name_s; @name.ljust(6); end
  def size_s; @size.to_s; end
  def time_s(meas); self.send(meas).to_s.rjust(7); end

  def basis_s(meas, time)
    diff = (time - self.send(meas))
    perc = ((diff / time) * 100).round
    if diff >= 0
      ANSI.green + "+#{diff} ms, +#{perc}%" + ANSI.reset
    else
      ANSI.red + "#{diff} ms, #{perc}%" + ANSI.reset
    end
  end

end

class UndiesResults < BenchResults

  def initialize(size='large')
    super(:undies, '.rb', size)
    measure do
      Undies::Template.new(
        Undies::Source.new(self.file),
        {},
        Undies::Output.new(self.outstream, :pp => 2)
      )
    end
  end

end

class ErbResults < BenchResults

  def initialize(size='large')
    super(:erb, '.erb', size)
    measure do
      self.out = ERB.new(File.read(self.file), 0, "%<>").result(binding)
    end
  end

end

class ErubisResults < BenchResults

  def initialize(size='large')
    super(:erubis, '.erb', size)
    measure do
      self.out = Erubis::Eruby.new(File.read(self.file)).result(binding)
    end
  end

end

class UndiesBenchRunner

  SIZES = {
    :small => "~20 nodes",
    :large => "~2000 nodes",
    :verylarge => "~20000 nodes"
  }

  def initialize
    puts "Benchmark Results:"
    puts
    [:small, :large, :verylarge].each do |size|
      puts "#{size.to_s.upcase} (#{SIZES[size]})"
      puts '-'*(size.to_s.length+3+SIZES[size].length)
      basis = UndiesResults.new(size)
      puts basis.to_s(:real)
      puts ErbResults.new(size).to_s(:real, basis.real)
      puts ErubisResults.new(size).to_s(:real, basis.real)
      puts
    end
  end

end
