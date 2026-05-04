# frozen_string_literal: true

require "bundler/setup"
require "uniword"
require "canon/rspec_matchers"

# Patch Canon::Comparison::CompareProfile to treat :namespace_declarations
# as informative (non-normative) rather than normative.
#
# According to W3C XML Namespaces specification, prefixed namespace declarations
# (xmlns:prefix="uri") and default namespace declarations (xmlns="uri") are
# semantically equivalent when they reference the same URI. The difference is
# only presentation format.
#
# lutaml-model serializes child elements with different namespaces using default
# namespace format, while the original OOXML files may use prefixed format.
# This patch ensures Canon recognizes these as semantically equivalent.
module Canon
  module Comparison
    class CompareProfile
      original_normative_dimension = instance_method(:normative_dimension?)

      define_method(:normative_dimension?) do |dimension|
        # Treat namespace_declarations as informative (non-normative)
        return false if dimension == :namespace_declarations

        # Use original logic for other dimensions
        original_normative_dimension.bind_call(self, dimension)
      end
    end
  end
end

# Use spec_friendly profile for attribute_order tolerant comparison
Canon::Config.configure do |config|
  config.xml.match.profile = :spec_friendly
  config.xml.diff.show_diffs = :normative
end

# Load support files
Dir[File.join(__dir__, "support", "**", "*.rb")].each { |f| require f }

FIXTURES_DIR = File.expand_path("#{__dir__}/fixtures")

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = "spec/examples.txt"
  config.disable_monkey_patching!
  config.warnings = true
  config.default_formatter = "doc" if config.files_to_run.one?
  config.order = :random
  Kernel.srand config.seed

  # Create test_output directory if it doesn't exist
  config.before(:suite) do
    FileUtils.mkdir_p("test_output")
  end

  # Skip LibreOffice tests if soffice is not available
  config.before do |example|
    if example.metadata[:skip_if_no_libreoffice]
      skip_理由 = if soffice_available?
                  nil
                else
                  "LibreOffice not installed. Install with: brew install --cask libreoffice (macOS) or apt-get install libreoffice (Linux)"
                end
      skip(skip_理由) if skip_理由
    end
  end
end

# Helper to check if soffice is available
def soffice_available?
  return true if system("which soffice > /dev/null 2>&1")

  File.exist?("/Applications/LibreOffice.app/Contents/MacOS/soffice")
end

# Helper to check if hunspell is available
def hunspell_available?
  system("which hunspell > /dev/null 2>&1")
end

# Global helper to safely delete files on Windows (handles file locking)
# Use this instead of File.delete when cleaning up temp files in specs
def safe_delete(path)
  return unless path && File.exist?(path)

  retries = 5
  begin
    File.delete(path)
  rescue Errno::EACCES
    if retries > 0
      sleep(0.2)
      retries -= 1
      retry
    end
  end
end

# Global helper to safely remove files using FileUtils.rm_f on Windows
# FileUtils.rm_f suppresses errors but can still fail with EACCES on locked files
def safe_rm_f(path)
  return unless path

  retries = 5
  begin
    FileUtils.rm_f(path)
  rescue Errno::EACCES
    if retries > 0
      sleep(0.2)
      retries -= 1
      retry
    end
  end
end
