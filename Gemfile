# frozen_string_literal: true

source "https://rubygems.org"

gemspec

# Validated stack pins (2026-10-18): leptris 1.9.390.x regressed
# imported-attribute XSD resolution -- a:blip r:embed falsely
# "not declared (strict)" (leptris-ruby#569). The 368.1 trio is the
# last fully-green pair (corpus 97/0, docx 385/0, 1623 gates, and the
# best recent hydration at 3.46s CPU). Lift when #569 ships.
gem "leptris", "1.9.368.1"
gem "moxml", "0.5.141"
gem "lutaml-model", "0.8.113"

# Standard library gems that will be removed from default in Ruby 4.0
gem "benchmark"

gem "benchmark-ips"
gem "benchmark-memory"
gem "canon"
gem "get_process_mem"
gem "nokogiri", "~> 1.19" # Moxml adapter for spec comparisons
gem "rake"
gem "rspec"
gem "rubocop"
gem "rubocop-performance"
gem "rubocop-rake"
gem "rubocop-rspec"
gem "ruby-prof"
gem "yard"
