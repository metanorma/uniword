# frozen_string_literal: true

source "https://rubygems.org"

gemspec

# Math equation support via Plurimath
gem "plurimath", "~> 0.10"

# Local development: use bleeding-edge local checkouts when present.
# CI environments fall back to the published rubygems versions.
#
# Keep each local-checkout gem as single-line statement(s) whose text includes
# the gem name. metanorma/ci's dependent-repos job strips every Gemfile line
# containing the gem name before running `bundle add`; a multi-line if/else
# would drop its variable definition or leave a dangling `end` and break
# bundler on downstream CI.
repo_root = File.expand_path("../..", __dir__)

lutaml_local = File.join(repo_root, "lutaml/lutaml-model")
gem "lutaml-model", path: lutaml_local if File.exist?(lutaml_local)

moxml_local = File.join(repo_root, "lutaml/moxml")
moxml_spec = File.exist?(moxml_local) ? { path: moxml_local } : ">= 0.1.15"
gem "moxml", moxml_spec

omml_local = File.join(repo_root, "plurimath/omml")
if File.exist?(omml_local)
  gem "omml", path: omml_local
end

# Standard library gems that will be removed from default in Ruby 4.0
gem "benchmark"

# rake is needed by `bundle exec rake release` which runs with
# --without development; must not be in the :development group.
gem "rake"

group :development do
  gem "canon"
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
