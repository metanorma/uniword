# frozen_string_literal: true

source "https://rubygems.org"

gemspec

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

# moxml 0.5.167 regressed same_node? on Leptris::XML::Attr (c_ptr); fixed in 0.5.168.
gem "moxml", "~> 0.6.0"

# lutaml-model 0.8.138-0.8.147 emit render_default: false booleans; fixed in
# 0.8.148 (lutaml-model#1057). 0.8.138+ also runs custom-initialize classes
# through the constructor during XML parsing, costing +50% hydration CPU on
# the uniword corpus (lutaml-model#1059).
gem "lutaml-model", "~> 0.8.161"

# leptris 1.9.386-1.9.390 reject r:embed on a:blip; fixed in 1.9.391 (leptris-ruby#569).
gem "leptris", "~> 1.9.391"

# Coradoc bridge (issue #80): plain-text editing round trip. DEV-only --
# optional at runtime (lazy requires), never in the gemspec, so no
# dependency cycle with coradoc-docx which depends on uniword.
gem "coradoc", "~> 2.0"
gem "coradoc-docx", "~> 0.1.5"
gem "coradoc-markdown", "~> 1.0.14"
gem "coradoc-adoc", "~> 2.0"
