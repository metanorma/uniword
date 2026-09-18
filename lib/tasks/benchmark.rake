# frozen_string_literal: true

desc "Run the deterministic performance benchmark"
task :benchmark do
  iterations = ENV.fetch("BENCH_ITERATIONS", "5")
  sh "bundle exec ruby benchmark/performance.rb --iterations #{iterations}"
end
