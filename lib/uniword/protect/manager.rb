# frozen_string_literal: true

module Uniword
  module Protect
    # Manages document protection settings.
    #
    # Provides operations for setting editing restrictions and
    # password protection on documents.
    #
    # Protection types:
    # - :read_only — no edits allowed
    # - :comments — only comments allowed
    # - :tracked_changes — only tracked changes allowed
    # - :forms — only form fields editable
    #
    # @example Set read-only protection
    #   manager = Manager.new(doc)
    #   manager.apply(:read_only, password: "secret")
    #
    # @example Remove protection
    #   manager.remove
    class Manager
      PROTECTION_TYPES = %i[
        read_only
        comments
        tracked_changes
        forms
      ].freeze

      attr_reader :document

      # Initialize with a document.
      #
      # @param document [Wordprocessingml::DocumentRoot]
      def initialize(document)
        @document = document
        @protection = nil
      end

      # Apply editing restriction to the document.
      #
      # @param protection_type [Symbol] One of PROTECTION_TYPES
      # @param password [String, nil] Optional password
      # @return [void]
      # @raise [ArgumentError] If protection_type is invalid
      def apply(protection_type, password: nil)
        validate_type(protection_type)

        @protection = build_protection(protection_type, password)
      end

      # Remove all protection from the document.
      #
      # @return [void]
      def remove
        @protection = nil
      end

      # Check if the document is protected.
      #
      # @return [Boolean]
      def protected?
        !@protection.nil?
      end

      # Get current protection info.
      #
      # @return [Hash, nil] Protection details or nil
      def info
        return nil unless @protection

        {
          type: protection_type(@protection),
          password_protected: password_protected?(@protection)
        }
      end

      private

      def validate_type(type)
        return if PROTECTION_TYPES.include?(type)

        raise ArgumentError,
              "Invalid protection type: #{type}. " \
              "Must be one of: #{PROTECTION_TYPES.join(", ")}"
      end

      def build_protection(type, password)
        result = {
          edit: map_type(type),
          enforcement: true
        }
        result[:password_hash] = hash_password(password) if password
        result
      end

      def map_type(type)
        case type
        when :read_only then "readOnly"
        when :comments then "comments"
        when :tracked_changes then "trackedChanges"
        when :forms then "forms"
        end
      end

      def hash_password(password)
        return nil unless password

        require "digest"
        Digest::SHA256.hexdigest(password)[0..31]
      end

      def protection_type(protection)
        return :unknown unless protection.is_a?(Hash)
        protection[:edit]&.to_sym || :unknown
      end

      def password_protected?(protection)
        protection.is_a?(Hash) && protection[:password_hash].to_s != ""
      end
    end
  end
end
