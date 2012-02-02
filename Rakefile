require 'assert/rake_tasks'
Assert::RakeTasks.for(:test)

require 'bundler'
Bundler::GemHelper.install_tasks

task :default => :run_all

desc "Run the profiler on the large bench template."
task :run_profiler do
  require 'bench/profiler_runner'
  UndiesProfilerRunner.new('large').print_flat(STDOUT, :min_percent => 3)
end

desc "Run the benchmark script."
task :run_bench do
  require 'bench/bench_runner'
  UndiesBenchRunner.new
end

desc "Run all the tests, then the profiler, then the bench."
task :run_all do
  Rake::Task['test'].invoke
  puts
  Rake::Task['run_profiler'].invoke
  puts
  Rake::Task['run_bench'].invoke
end

