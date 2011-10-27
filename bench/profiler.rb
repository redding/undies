require 'ruby-prof'
require 'undies'
require 'bench/procs'

file = "bench/#{ARGV[0] || 'large'}.html.rb"
proc = eval("@#{ARGV[0] || 'large'}_proc")
result = nil

File.open('bench/output.txt', 'a+') do |outstream|

  output = Undies::Output.new(outstream, :pp => 2)

  result = RubyProf.profile do
    50.times do
      Undies::Template.new(Undies::Source.new(File.expand_path(file)), {}, output)
    end
    50.times do
      Undies::Template.new(Undies::Source.new(proc), {}, output)
    end
  end

end

printer = RubyProf::FlatPrinter.new(result).print(STDOUT, :min_percent => 1)
# printer = RubyProf::GraphPrinter.new(result).print(STDOUT)
