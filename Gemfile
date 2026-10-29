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

# moxml 0.5.167 regressed same_node? on Leptris::XML::Attr (c_ptr); fixed in 0.5.168
gem "moxml", ">= 0.5.168"

# lutaml-model 0.8.138+ constructs custom-initialize classes through the constructor, and the
# writer_populated? check (#922) then marks their defaults as set, so render_default: false
# booleans (pPr bidi, suppressLineNumbers) are emitted. 0.8.137 is good; 0.8.147 still bad.
gem "lutaml-model", "0.8.137"
