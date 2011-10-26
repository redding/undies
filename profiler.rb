require 'ruby-prof'
require 'undies'

file = "test/templates/#{ARGV[0]}.html.rb"
out = ""
outstream = StringIO.new(out)
output = Undies::Output.new(outstream, :pp => 2)

result = RubyProf.profile do
  50.times do
    Undies::Template.new(Undies::Source.new(File.expand_path(file)), {}, output)
  end
end

printer = RubyProf::FlatPrinter.new(result).print(STDOUT, :min_percent => 1)
# printer = RubyProf::GraphPrinter.new(result).print(STDOUT)
