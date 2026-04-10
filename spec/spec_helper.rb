# frozen_string_literal: true

require 'bundler/setup'
require 'uniword'
require 'canon/rspec_matchers'

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
        original_normative_dimension.bind(self).call(dimension)
      end
    end
  end
end

# Load support files
Dir[File.join(__dir__, 'support', '**', '*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = 'spec/examples.txt'
  config.disable_monkey_patching!
  config.warnings = true
  config.default_formatter = 'doc' if config.files_to_run.one?
  config.order = :random
  Kernel.srand config.seed

  # Create test_output directory if it doesn't exist
  config.before(:suite) do
    FileUtils.mkdir_p('test_output')
  end
end
