require 'assert/rake_tasks'
Assert::RakeTasks.for(:test)

require 'bundler'
Bundler::GemHelper.install_tasks

task :default => :build

namespace :bench do

  desc "Run the bench script."
  task :run do
    require 'bench/bench_runner'
    UndiesBenchRunner.new
  end

  desc "Run the profiler on 1000 rows."
  task :profiler do
    require 'bench/profiler_runner'
    UndiesProfilerRunner.new('verylarge').print_flat(STDOUT, :min_percent => 1)
  end

  desc "Run all the tests, then the profiler, then the bench."
  task :all do
    Rake::Task['test'].invoke
    puts
    Rake::Task['bench:profiler'].invoke
    puts
    Rake::Task['bench:run'].invoke
  end

end

task :bench do
  Rake::Task['bench:run'].invoke
end

