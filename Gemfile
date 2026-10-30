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
# 0.5.174 refuses leptris below 1.9.386 and falls back to nokogiri, while leptris stays
# on 1.9.385 below.
gem "moxml", ">= 0.5.168", "< 0.5.174"

# lutaml-model 0.8.138 to 0.8.147 emit render_default: false booleans (pPr bidi,
# suppressLineNumbers) for custom-initialize classes; fixed in 0.8.148 (lutaml-model#1057).
gem "lutaml-model", ">= 0.8.148"

# leptris 1.9.386 rejects r:embed on a:blip ("attribute 'embed': not declared") in
# xsd_output_validation_spec; 1.9.385 is good.
gem "leptris", "1.9.385.0"
