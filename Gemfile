# frozen_string_literal: true

source "https://rubygems.org"

gemspec

# Math equation support via Plurimath
gem "plurimath", "~> 0.10"

# lutaml-model is already in gemspec as add_dependency

gem "moxml", ">= 0.1.15"

# Standard library gems that will be removed from default in Ruby 4.0
gem "benchmark"

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
  gem "benchmark-ips"
  gem "benchmark-memory"
  gem "get_process_mem"
  gem "ruby-prof"
end
