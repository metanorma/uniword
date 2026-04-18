# frozen_string_literal: true

source "https://rubygems.org"

gemspec

# Math equation support via Plurimath
# gem 'plurimath', path: '/Users/mulgogi/src/plurimath/plurimath'

gem 'lutaml-model', github: 'lutaml/lutaml-model', branch: 'main'

group :development do
  gem "canon"
  gem "rake"
  gem "rspec"
  gem "rubocop"
  gem "rubocop-performance"
  gem "rubocop-rake"
  gem "rubocop-rspec"
  gem "yard"
end

group :profiling, optional: true do
  gem "benchmark"
  gem "benchmark-ips"
  gem "benchmark-memory"
  gem "get_process_mem"
  gem "ruby-prof"
end

