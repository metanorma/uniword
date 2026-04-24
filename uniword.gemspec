# frozen_string_literal: true

require_relative "lib/uniword/version"

Gem::Specification.new do |spec|
  spec.name        = "uniword"
  spec.version     = Uniword::VERSION
  spec.authors     = ["Ribose Inc."]
  spec.email       = ["open.source@ribose.com"]
  spec.homepage    = "https://github.com/metanorma/uniword"
  spec.summary     = "Read and write Word documents (DOCX and MHTML)"
  spec.description = "Comprehensive Ruby library for creating and manipulating Microsoft Word " \
                     "documents in DOCX and MHTML formats. Features include full formatting support, " \
                     "tables, lists, images, headers/footers, styles, and bidirectional format conversion."
  spec.license     = "BSD-2-Clause"

  spec.metadata = {
    "bug_tracker_uri" => "https://github.com/metanorma/uniword/issues",
    "homepage_uri" => spec.homepage,
    "source_code_uri" => "https://github.com/metanorma/uniword",
    "changelog_uri" => "https://github.com/metanorma/uniword/blob/main/CHANGELOG.md",
    "documentation_uri" => "https://www.rubydoc.info/gems/uniword",
    "rubygems_mfa_required" => "true",
  }

  spec.files = Dir.glob(%w[
                          lib/**/*.rb
                          lib/**/*.css
                          exe/*
                          data/**/*.yml
                          data/**/*.xsd
                          config/**/*.yml
                          README.adoc
                          CHANGELOG.md
                          CONTRIBUTING.md
                          LICENSE.txt
                        ])
  spec.bindir = "exe"
  spec.executables = ["uniword"]
  spec.require_paths = ["lib"]
  spec.required_ruby_version = ">= 3.0.0"

  # Core dependencies
  spec.add_dependency "logger" # stdlib gem, extracted in Ruby 4.0
  spec.add_dependency "lutaml-model", "~> 0.8.0"
  spec.add_dependency "nokogiri", "~> 1.19"
  spec.add_dependency "rainbow", "~> 3.1"
  spec.add_dependency "rubyzip", "~> 2.3"
  spec.add_dependency "thor", "~> 1.3"
end
