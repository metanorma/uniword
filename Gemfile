# frozen_string_literal: true

source "https://rubygems.org"

gemspec

# Math equation support via Plurimath
gem "plurimath", "~> 0.10"

# Local development: use bleeding-edge local checkouts when present.
# CI environments fall back to the published rubygems versions.
repo_root = File.expand_path("../..", __dir__)

lutaml_local = File.join(repo_root, "lutaml/lutaml-model")
if File.exist?(lutaml_local)
  gem "lutaml-model", path: lutaml_local
end

moxml_local = File.join(repo_root, "lutaml/moxml")
if File.exist?(moxml_local)
  gem "moxml", path: moxml_local
else
  gem "moxml", ">= 0.1.15"
end

omml_local = File.join(repo_root, "plurimath/omml")
if File.exist?(omml_local)
  gem "omml", path: omml_local
end

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
