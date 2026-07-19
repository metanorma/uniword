# frozen_string_literal: true

module Uniword
  module Docx
    class Reconciler
      EXTENSION_PREFIXES = Ooxml::Namespaces::EXTENSION_PREFIXES
      FULL_IGNORABLE = Ooxml::Namespaces::FULL_IGNORABLE_PREFIXES

      VALID_NOTE_TYPES = %w[separator continuationSeparator
                            footnoteSeparator continuationNotice].freeze

      # Sub-modules autoloaded — registered below, loaded on first use.
      autoload :Fix, "#{__dir__}/reconciler/fix"
      autoload :FixCodes, "#{__dir__}/reconciler/fix_codes"
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

      def initialize(package, profile: nil, allocator: nil,
                     builder_managed: nil)
        @package = package
        @profile = profile
        @allocator = allocator
        @builder_managed = if builder_managed.nil?
                             !allocator.nil? || !package.allocator.nil?
                           else
                             builder_managed
                           end
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

      # Audit trail of repairs applied during reconciliation.
      #
      # @return [Array<Fix>] Fixes recorded by the most recent #reconcile
      attr_reader :applied_fixes

      private

      attr_reader :package, :profile

      # The single rId/ID authority for this run. Falls back to an
      # allocator populated from the package when the package carries
      # none (direct Reconciler use outside Package#to_zip_content).
      def allocator
        @allocator ||= package.allocator ||
          IdAllocator.populate_from_package(package)
      end

      # Whether the document's IDs were managed outside the reconciler
      # (builder-created content, or a package loaded with an explicit
      # allocator). Builder-managed documents get light-touch repairs;
      # legacy documents get the full normalization repertoire (ID
      # backfill, table normalization, note renumbering). rIds flow
      # through the allocator either way. Decided at initialize time.
      def builder_managed?
        @builder_managed
      end

      # Record one applied repair as a Fix value object.
      #
      # @param code [String] Fix code (a FixCodes constant value)
      # @param message [String] Human-readable description of the repair
      # @param part [String, nil] Package part the repair applies to
      def record_fix(code, message, part: nil)
        @applied_fixes << Fix.new(code: code, message: message, part: part)
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
          package.comments,
        ].compact

        (package.document&.header_footer_parts || []).each do |part|
          parts << part.content if part.content
        end

        parts.each do |part|
          part.import_declaration_plan = nil
          part.pending_plan_root_element = nil
        end
      end
    end
  end
end
