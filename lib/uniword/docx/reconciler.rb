# frozen_string_literal: true

require_relative "reconciler/helpers"
require_relative "reconciler/notes"
require_relative "reconciler/referential_integrity"
require_relative "reconciler/tables"
require_relative "reconciler/theme"
require_relative "reconciler/parts"
require_relative "reconciler/package_structure"
require_relative "reconciler/body"

module Uniword
  module Docx
    # Reconciles DOCX-level invariants before serialization.
    #
    # Ensures that the document's model state is internally consistent so that
    # the serialized output is always a valid DOCX file. Called from
    # Docx::Package#to_zip_content before the serialization phase.
    #
    # This is not an extension point -- it enforces built-in invariants.
    # For customizable validation, use Uniword::Validation::Rules instead.
    # For user-defined requirements, use Docx::Requirement (future).
    #
    # Composed of focused modules:
    # - Helpers: ID generation, traversal, run utilities
    # - Notes: footnote/endnote reconciliation
    # - ReferentialIntegrity: cross-part ID consistency
    # - Tables: table structure repair
    # - Theme: theme creation and repair
    # - Parts: profile-dependent support parts
    # - PackageStructure: content types and relationships
    # - Body: section properties, headers/footers
    class Reconciler
      # mc:Ignorable prefixes — derived from Ooxml::Namespaces::EXTENSION_NAMESPACES.
      EXTENSION_PREFIXES = Ooxml::Namespaces::EXTENSION_PREFIXES
      FULL_IGNORABLE = Ooxml::Namespaces::FULL_IGNORABLE_PREFIXES

      # Valid w:type values per OOXML spec for w:footnote/w:endnote.
      VALID_NOTE_TYPES = %w[separator continuationSeparator
                            footnoteSeparator continuationNotice].freeze

      include Helpers
      include Notes
      include ReferentialIntegrity
      include Tables
      include Theme
      include Parts
      include PackageStructure
      include Body

      def initialize(package, profile: nil)
        @package = package
        @profile = profile
        @applied_fixes = []
      end

      def reconcile
        # Group 1: Document body (always)
        reconcile_section_properties
        reconcile_footnotes
        reconcile_endnotes
        reconcile_headers_footers
        reconcile_tables
        repair_theme
        reconcile_referential_integrity

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
      end

      # Audit trail of fixes applied during reconciliation.
      attr_reader :applied_fixes

      private

      attr_reader :package, :profile

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
