# frozen_string_literal: true

module Uniword
  # Global runtime configuration for Uniword.
  #
  # Holds save-path policy as plain, explicitly typed boolean attributes.
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

    # Create a configuration with default policy values.
    #
    # Defaults: validate_on_save: true, xsd_validation: false,
    # log_save_fixes: true.
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
  end
end
