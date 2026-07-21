# frozen_string_literal: true

module Uniword
  module Docx
    # Reporting record for a part stripped at load time.
    #
    # Created by `Docx::PartLoader` (in `:strip` policy mode) for
    # every ZIP entry the `JunkClassifier` flagged. Stored on
    # `Package#stripped_parts` for caller introspection.
    #
    # Lightweight by design: no lutaml-model, no XML serialization.
    # These are load-time metadata, never written to a package.
    #
    # @example
    #   part = StrippedPart.new(
    #     path: "[trash]/0000.dat",
    #     reason: "No content type declaration and no referencing " \
    #             "relationship",
    #   )
    #   part.path   # => "[trash]/0000.dat"
    #   part.reason # => "No content type declaration..."
    class StrippedPart
      attr_reader :path, :reason

      # @param path [String] package-relative path of the stripped part
      # @param reason [String] why the part was stripped (human-readable,
      #   produced by `JunkClassifier#reason`)
      def initialize(path:, reason:)
        @path = path
        @reason = reason
      end

      # Value-object equality by path + reason.
      #
      # @param other [Object]
      # @return [Boolean]
      def eql?(other)
        other.is_a?(StrippedPart) && path == other.path &&
          reason == other.reason
      end

      # Combined with `eql?` for Hash/Set membership.
      #
      # @return [Integer]
      def hash
        [path, reason].hash
      end

      # @param other [Object]
      # @return [Boolean]
      def ==(other)
        eql?(other)
      end
    end
  end
end
