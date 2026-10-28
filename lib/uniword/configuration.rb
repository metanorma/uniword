# frozen_string_literal: true

module Uniword
  # Global runtime configuration for Uniword.
  #
  # Holds save-path policy as plain, explicitly typed attributes.
  # This object is runtime policy only: it has no file-loading behavior
  # (see ConfigurationLoader for external YAML config files) and no
  # serialization behavior.
  #
  # This class also serves as the namespace for configuration-related
  # classes (ConfigurationLoader, ConfigurationError).
  #
  # @example Read current policy
  #   Uniword.configuration.validate_on_save # => true
  #
  # @example Change policy via Uniword.configure
  #   Uniword.configure do |config|
  #     config.xsd_validation = true
  #   end
  class Configuration
    autoload :ConfigurationLoader,
             "#{__dir__}/configuration/configuration_loader"

    # Accepted values for `on_noncompliant_content`.
    #
    # `:strip` — Word-identical default: non-compliant parts are
    #   dropped at load and recorded on `Package#stripped_parts`.
    # `:raise` — strict: parts are preserved; the save-time
    #   `PackageIntegrityChecker` raises `Uniword::ValidationError`
    #   with structured OPC-005 issues.
    ON_NONCOMPLIANT_MODES = %i[strip raise].freeze

    # Whether documents are validated when saved.
    #
    # @return [Boolean]
    attr_reader :validate_on_save

    # Whether XSD schema validation runs on save (slower, stricter).
    #
    # @return [Boolean]
    attr_reader :xsd_validation

    # Whether automatic fixes applied during save are logged.
    #
    # @return [Boolean]
    attr_reader :log_save_fixes

    # Load-time policy for non-compliant parts (no content type
    # declaration, OS artifact, ...).
    #
    # @return [Symbol] `:strip` (default) or `:raise`
    attr_reader :on_noncompliant_content

    # Whether save produces deterministic output (fixed ZIP
    # timestamps, sorted entry order). Default false (Word-compatible
    # timestamps and order). Enable for git-tracked documents where
    # byte-stable diffs matter.
    #
    # @return [Boolean]
    attr_reader :deterministic_output

    # Create a configuration with default policy values.
    #
    # Defaults: validate_on_save: true, xsd_validation: false,
    # log_save_fixes: true, on_noncompliant_content: :strip.
    def initialize
      reset!
    end

    # Restore all attributes to their default values.
    #
    # @return [Configuration] self
    def reset!
      @validate_on_save = true
      @xsd_validation = false
      @log_save_fixes = true
      @on_noncompliant_content = :strip
      @deterministic_output = false
      self
    end

    # Set the validate-on-save policy.
    #
    # @param value [Boolean] new value
    # @return [Boolean] the value set
    # @raise [ArgumentError] if value is not true or false
    def validate_on_save=(value)
      @validate_on_save = typed_boolean(value, :validate_on_save)
    end

    # Set the XSD validation policy.
    #
    # @param value [Boolean] new value
    # @return [Boolean] the value set
    # @raise [ArgumentError] if value is not true or false
    def xsd_validation=(value)
      @xsd_validation = typed_boolean(value, :xsd_validation)
    end

    # Set the save-fix logging policy.
    #
    # @param value [Boolean] new value
    # @return [Boolean] the value set
    # @raise [ArgumentError] if value is not true or false
    def log_save_fixes=(value)
      @log_save_fixes = typed_boolean(value, :log_save_fixes)
    end

    # Set the non-compliant-content policy. Accepts symbols or
    # strings; stored as a symbol.
    #
    # @param value [Symbol, String] `:strip` or `:raise`
    # @return [Symbol] the value set
    # @raise [ArgumentError] if value is not one of
    #   `ON_NONCOMPLIANT_MODES`
    def on_noncompliant_content=(value)
      @on_noncompliant_content = typed_mode(value, :on_noncompliant_content)
    end

    # Set the deterministic-output policy.
    #
    # @param value [Boolean]
    # @return [Boolean]
    def deterministic_output=(value)
      @deterministic_output = typed_boolean(value, :deterministic_output)
    end

    private

    # Validate that a value is strictly boolean.
    #
    # @param value [Object] value to check
    # @param name [Symbol] attribute name used in the error message
    # @return [Boolean] the value
    # @raise [ArgumentError] if value is not true or false
    def typed_boolean(value, name)
      return value if value.is_a?(TrueClass) || value.is_a?(FalseClass)

      raise ArgumentError,
            "#{name} must be true or false, got #{value.inspect}"
    end

    # Validate that a value is one of the accepted non-compliant modes.
    #
    # @param value [Object] value to check (Symbol or String)
    # @param name [Symbol] attribute name used in the error message
    # @return [Symbol] the value as a symbol
    # @raise [ArgumentError] if value is not in ON_NONCOMPLIANT_MODES
    def typed_mode(value, name)
      sym = symbol_value(value)
      return sym if ON_NONCOMPLIANT_MODES.include?(sym)

      raise ArgumentError,
            "#{name} must be one of #{ON_NONCOMPLIANT_MODES.inspect}, " \
            "got #{value.inspect}"
    end

    # Coerce a value to a Symbol when it is a Symbol or String.
    #
    # @param value [Object]
    # @return [Symbol, nil] nil when value is neither Symbol nor String
    def symbol_value(value)
      return value if value.is_a?(Symbol)
      return value.to_sym if value.is_a?(String)

      nil
    end
  end
end
