# frozen_string_literal: true

module Uniword
  module Docx
    class Reconciler
      # A single repair applied by the Reconciler during save.
      #
      # Immutable value object exposed as the reconciliation report via
      # `Package#applied_fixes` after a save. The Reconciler stays the only
      # mutating pass; this report is a by-product value, not a global.
      #
      # @example Inspect fixes after save
      #   package.to_file("out.docx")
      #   package.applied_fixes.each do |fix|
      #     puts "#{fix.code} [#{fix.part}] #{fix.message}"
      #   end
      class Fix
        # @return [String] Fix code (see Reconciler::FixCodes)
        attr_reader :code

        # @return [String] Human-readable description of the repair
        attr_reader :message

        # @return [String, nil] Package part the repair applies to
        attr_reader :part

        # Create a fix record.
        #
        # @param code [String] Fix code (a FixCodes constant value)
        # @param message [String] Human-readable description of the repair
        # @param part [String, nil] Package part the repair applies to
        def initialize(code:, message:, part: nil)
          @code = code
          @message = message
          @part = part
        end

        # @return [String] Compact single-line representation
        def to_s
          location = part ? " [#{part}]" : ""
          "#{code}#{location}: #{message}"
        end
      end
    end
  end
end
