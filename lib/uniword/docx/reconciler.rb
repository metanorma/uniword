# frozen_string_literal: true

module Uniword
  module Docx
    class Reconciler
      EXTENSION_PREFIXES = Ooxml::Namespaces::EXTENSION_PREFIXES
      FULL_IGNORABLE = Ooxml::Namespaces::FULL_IGNORABLE_PREFIXES

      VALID_NOTE_TYPES = %w[separator continuationSeparator
                            footnoteSeparator continuationNotice].freeze

      # Sub-modules autoloaded — no require_relative for internal code.
      autoload :Helpers, "#{__dir__}/reconciler/helpers"
      autoload :Notes, "#{__dir__}/reconciler/notes"
      autoload :ReferentialIntegrity, "#{__dir__}/reconciler/referential_integrity"
      autoload :Tables, "#{__dir__}/reconciler/tables"
      autoload :Theme, "#{__dir__}/reconciler/theme"
      autoload :Parts, "#{__dir__}/reconciler/parts"
      autoload :PackageStructure, "#{__dir__}/reconciler/package_structure"
      autoload :Body, "#{__dir__}/reconciler/body"

      include Helpers
      include Notes
      include ReferentialIntegrity
      include Tables
      include Theme
      include Parts
      include PackageStructure
      include Body

      def initialize(package, profile: nil, allocator: nil)
        @package = package
        @profile = profile
        @allocator = allocator
        @applied_fixes = []
      end

      def reconcile
        # Group 1: Document body (always)
        reconcile_section_properties
        reconcile_footnotes
        reconcile_endnotes
        reconcile_note_references
        reconcile_headers_footers
        reconcile_tables
        repair_theme

        # Group 2: Support parts (profile-dependent)
        if @profile
          reconcile_theme
          reconcile_settings
          reconcile_font_table
          reconcile_styles
          reconcile_numbering
          reconcile_web_settings
          reconcile_app_properties
          reconcile_core_properties
          reconcile_document_body
        end

        # Clear stored namespace plans so declare: :always scopes take effect
        clear_stored_namespace_plans

        # Group 3: Package consistency (always)
        reconcile_content_types
        reconcile_package_rels
        reconcile_document_rels

        # Group 4: Integrity checks (after rels are assembled)
        reconcile_referential_integrity
      end

      # Audit trail of fixes applied during reconciliation.
      attr_reader :applied_fixes

      private

      attr_reader :package, :profile

      def allocator
        @allocator || package.allocator
      end

      def record_fix(validity_rule, message)
        @applied_fixes << {
          validity_rule: validity_rule,
          message: message,
          timestamp: Time.now,
        }
      end

      def clear_stored_namespace_plans
        parts = [
          package.document,
          package.settings,
          package.font_table,
          package.styles,
          package.web_settings,
          package.numbering,
          package.core_properties,
          package.app_properties,
          package.footnotes,
          package.endnotes,
        ].compact

        (package.document&.header_footer_parts || []).each do |part|
          parts << part[:content] if part[:content]
        end

        (package.document&.headers&.values || []).each { |h| parts << h }
        (package.document&.footers&.values || []).each { |f| parts << f }

        parts.each(&:clear_xml_parse_state!)
      end
    end
  end
end
