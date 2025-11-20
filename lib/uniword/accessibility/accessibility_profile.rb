# frozen_string_literal: true

module Uniword
  module Accessibility
    # Accessibility Profile - configuration for accessibility checking profile
    #
    # Responsibility: Load and manage profile configuration
    # Single Responsibility: Profile configuration management only
    #
    # @example Loading a profile
    #   config = YAML.load_file('config/accessibility_profiles.yml')
    #   profile = AccessibilityProfile.load(config, :wcag_2_1_aa)
    class AccessibilityProfile
      attr_reader :name, :level, :rules, :inherits, :overrides

      # Load a profile from configuration
      #
      # @param config [Hash] Full configuration with profiles
      # @param profile_name [Symbol] Name of profile to load
      # @return [AccessibilityProfile] Loaded profile
      # @raise [ArgumentError] If profile not found
      def self.load(config, profile_name)
        profiles_config = config[:profiles] || config["profiles"]
        raise ArgumentError, "No profiles found in configuration" unless profiles_config

        profile_config = profiles_config[profile_name] || profiles_config[profile_name.to_s]
        raise ArgumentError, "Profile '#{profile_name}' not found" unless profile_config

        new(profile_config, profiles_config)
      end

      # Initialize a new accessibility profile
      #
      # @param config [Hash] Profile configuration
      # @param all_profiles [Hash] All available profiles (for inheritance)
      def initialize(config, all_profiles = {})
        @config = config
        @all_profiles = all_profiles
        @name = config[:name] || config["name"]
        @level = config[:level] || config["level"]
        @inherits = config[:inherits] || config["inherits"]
        @overrides = config[:overrides] || config["overrides"] || {}
        @rules = build_rules_config
      end

      # Get configuration for a specific rule
      #
      # @param rule_name [Symbol, String] Rule name
      # @return [Hash, nil] Rule configuration or nil
      def rule_config(rule_name)
        @rules[rule_name.to_sym] || @rules[rule_name.to_s]
      end

      # Check if a rule is enabled
      #
      # @param rule_name [Symbol, String] Rule name
      # @return [Boolean] True if rule is enabled
      def rule_enabled?(rule_name)
        config = rule_config(rule_name)
        return false unless config

        config.fetch(:enabled, config.fetch("enabled", true))
      end

      private

      # Build complete rules configuration with inheritance
      #
      # @return [Hash] Complete rules configuration
      def build_rules_config
        rules = {}

        # Start with inherited rules if any
        if @inherits
          parent_config = @all_profiles[@inherits] || @all_profiles[@inherits.to_s]
          if parent_config
            parent_profile = self.class.new(parent_config, @all_profiles)
            rules = parent_profile.rules.dup
          end
        end

        # Merge in this profile's rules
        profile_rules = @config[:rules] || @config["rules"] || {}
        rules.merge!(normalize_keys(profile_rules))

        # Apply overrides
        overrides_rules = @overrides[:rules] || @overrides["rules"] || @overrides
        if overrides_rules && !overrides_rules.empty?
          # Only apply overrides that affect existing rules
          normalize_keys(overrides_rules).each do |rule_name, override_config|
            if rules[rule_name]
              rules[rule_name] = deep_merge(rules[rule_name], override_config)
            end
          end
        end

        rules
      end

      # Normalize hash keys to symbols
      #
      # @param hash [Hash] Hash to normalize
      # @return [Hash] Hash with symbol keys
      def normalize_keys(hash)
        return {} unless hash.is_a?(Hash)

        hash.each_with_object({}) do |(key, value), result|
          normalized_key = key.to_sym
          result[normalized_key] = if value.is_a?(Hash)
                                      normalize_keys(value)
                                    else
                                      value
                                    end
        end
      end

      # Deep merge two hashes
      #
      # @param base [Hash] Base hash
      # @param override [Hash] Override hash
      # @return [Hash] Merged hash
      def deep_merge(base, override)
        return override unless base.is_a?(Hash) && override.is_a?(Hash)

        base.merge(override) do |_key, base_value, override_value|
          if base_value.is_a?(Hash) && override_value.is_a?(Hash)
            deep_merge(base_value, override_value)
          else
            override_value
          end
        end
      end
    end
  end
end