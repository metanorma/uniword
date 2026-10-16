# frozen_string_literal: true

source "https://rubygems.org"

gemspec

# Validated stack pins: leptris 1.9.354+ regressed XSD resolution
# (leptris-ruby#478) and 1.9.367 segfaults in Element hydration with
# moxml 0.5.140; moxml 0.5.136 + leptris 1.9.353.0 is the last pair
# where the corpus, detection gates, and hydration benchmark are all
# green (revisit when leptris-ruby#478 follow-ups ship).
gem "leptris", "1.9.365.1"
gem "moxml", "0.5.140"
gem "lutaml-model", "0.8.107"

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
