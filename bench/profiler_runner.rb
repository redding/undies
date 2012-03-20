require 'stringio'
require 'ruby-prof'
require 'undies'
require 'bench/procs'

class UndiesProfilerRunner

  attr_reader :result

  def initialize(size)
    file = "bench/#{size || 'large'}.html.rb"
    @source = Undies::Source.new(File.expand_path(file))
    @data = {}
    @output = Undies::Output.new(@out = "")

    @result = RubyProf.profile do
      10.times do
        Undies::Template.new(@source, @data, @output)
      end
    end

  end

  def print_flat(outstream, opts={})
    RubyProf::FlatPrinter.new(@result).print(outstream, opts)
  end

  def print_graph(outstream, opts={})
    RubyProf::GraphPrinter.new(@result).print(outstream, opts)
  end

end
