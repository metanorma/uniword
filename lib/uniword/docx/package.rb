# frozen_string_literal: true

require "securerandom"
require "lutaml/model"

module Uniword
  module Docx
    # DOCX Package - Complete DOCX file format model
    #
    # Represents the entire .docx file structure as a lutaml-model object.
    # Each XML file within the ZIP is a separate lutaml-model class.
    #
    # A DOCX package CONTAINS OOXML markup wrapped in an OPC ZIP container.
    # This class lives in Uniword::Docx, not Uniword::Ooxml, because
    # DOCX is a file format that uses OOXML, not the other way around.
    #
    # @example Load DOCX
    #   package = Package.from_file('document.docx')
    #   package.core_properties.title = 'New Title'
    #   package.to_file('output.docx')
    #
    # @example Access document content
    #   package = Package.from_file('document.docx')
    #   package.document.body.paragraphs.each { |p| puts p.text }
    class Package < Lutaml::Model::Serializable
      include PackageDefaults
      include PackageSerialization

      # === Package Structure (OOXML Part 2: OPC) ===
      # Content Types ([Content_Types].xml)
      attribute :content_types, Uniword::ContentTypes::Types

      # Package-level relationships (_rels/.rels)
      attribute :package_rels, Ooxml::Relationships::PackageRelationships

      # === Document Properties (docProps/) ===
      # Core document metadata (docProps/core.xml)
      attribute :core_properties, Ooxml::CoreProperties

      # Extended application properties (docProps/app.xml)
      attribute :app_properties, Ooxml::AppProperties

      # Custom document properties (docProps/custom.xml)
      attribute :custom_properties, Ooxml::CustomProperties

      # Custom XML data items (customXml/item*.xml)
      #
      # @return [Array<CustomXmlItem>, nil]
      attr_reader :custom_xml_items

      # Assign custom XML items; accepts CustomXmlItem objects and
      # legacy hashes ({ index:, xml_content:, props_xml:, rels_xml: }).
      def custom_xml_items=(items)
        @custom_xml_items = items && items.map { |i| CustomXmlItem.wrap(i) }
      end

      # === Document Parts (word/) ===
      # Main document content (word/document.xml)
      attribute :document, Uniword::Wordprocessingml::DocumentRoot

      # Document styles (word/styles.xml)
      attribute :styles, Uniword::Wordprocessingml::StylesConfiguration

      # Document numbering (word/numbering.xml)
      attribute :numbering, Uniword::Wordprocessingml::NumberingConfiguration

      # Document settings (word/settings.xml)
      attribute :settings, Uniword::Wordprocessingml::Settings

      # Document font table (word/fontTable.xml)
      attribute :font_table, Uniword::Wordprocessingml::FontTable

      # Document web settings (word/webSettings.xml)
      attribute :web_settings, Uniword::Wordprocessingml::WebSettings

      # Document-level relationships (word/_rels/document.xml.rels)
      attribute :document_rels, Ooxml::Relationships::PackageRelationships

      # === Theme (word/theme/) ===
      # Document theme (word/theme/theme1.xml)
      attribute :theme, Drawingml::Theme

      # Theme-level relationships (word/theme/_rels/theme1.xml.rels)
      attribute :theme_rels, Ooxml::Relationships::PackageRelationships

      # === Footnotes and Endnotes (word/) ===
      # Footnotes (word/footnotes.xml)
      attribute :footnotes, Uniword::Wordprocessingml::Footnotes

      # Endnotes (word/endnotes.xml)
      attribute :endnotes, Uniword::Wordprocessingml::Endnotes

      # Comments (word/comments.xml)
      attribute :comments, Uniword::CommentsPart

      # Non-serialized attributes (DOCX packaging helpers)
      attr_accessor :profile
      attr_accessor :settings_rels, :footnotes_rels, :endnotes_rels

      # OLE/embedded object binaries (word/embeddings/*), keyed by target.
      #
      # @return [PartCollection] target => Part
      def embeddings
        @embeddings ||= PartCollection.new(:target, Part)
      end

      # Bulk-assign embeddings (Hash of target => Part/binary; nil clears).
      def embeddings=(value)
        embeddings.replace_all(value)
      end

      # Raw passthrough parts no registry definition models, keyed by
      # package path ("docProps/meta.xml", "word/glossary/document.xml",
      # ...). Carried byte-for-byte from load to save — see
      # PartLoader::RawPartLoader for claiming and
      # PackageSerialization#serialize_raw_parts for emission.
      #
      # @return [PartCollection] package path => RawPart
      def raw_parts
        @raw_parts ||= PartCollection.new(:path, RawPart)
      end

      # Bulk-assign raw parts (Hash of path => RawPart/hash; nil clears).
      def raw_parts=(value)
        raw_parts.replace_all(value)
      end

      # Central ID allocator — owns all rId, footnote, bookmark, etc. assignment.
      # Seeded from template rels on load; used by builders during construction.
      attr_accessor :allocator

      # Raw XML from template ZIP for unmodified parts.
      # When present, these are used verbatim instead of re-serializing
      # through lutaml-model (which drops unmapped elements).
      attr_accessor :raw_xml_parts

      # Paths that have been modified and should not use raw XML passthrough.
      attr_accessor :modified_part_paths

      # Audit trail of repairs applied by the Reconciler during the most
      # recent save (to_zip_content). Empty before the first save and when
      # the package needed no repairs.
      #
      # @return [Array<Reconciler::Fix>] Fixes from the most recent save
      def applied_fixes
        @applied_fixes ||= []
      end

      # Load DOCX package from file
      #
      # @param path [String] Path to .docx file
      # @return [Package] Package with all parts loaded
      def self.from_file(path)
        extractor = Infrastructure::ZipExtractor.new
        zip_content = extractor.extract(path)
        package = from_zip_content(zip_content, path)
        package.populate_allocator
        package
      end

      # Create package from extracted ZIP content
      #
      # Parts load by iterating Ooxml::PartRegistry.loadable and
      # dispatching each definition to its Docx::PartLoader strategy —
      # see PartLoader for the load order and strategy registry.
      #
      # @param zip_content [Hash] Extracted ZIP files
      # @param zip_path [String, nil] Original ZIP path for binary re-extraction
      # @return [Package] Package object
      def self.from_zip_content(zip_content, zip_path = nil)
        package = new
        PartLoader.load(zip_content, package, zip_path: zip_path)
        package
      end

      # Save document to file (class method for DocumentWriter compatibility)
      #
      # @param document [Wordprocessingml::DocumentRoot] Document to save
      # @param path [String] Output file path
      # @param profile [Profile, nil] Reconciliation profile
      # @param validate [Boolean, nil] Run the package integrity gate before
      #   writing; nil falls back to Uniword.configuration.validate_on_save
      # @return [void]
      def self.to_file(document, path, profile: nil, validate: nil)
        package = new
        package.document = document
        package.profile = profile || Profile.defaults
        copy_document_parts_to_package(document, package)
        package.content_types ||= minimal_content_types
        package.package_rels ||= minimal_package_rels
        package.document_rels ||= minimal_document_rels
        package.settings ||= Uniword::Wordprocessingml::Settings.new
        package.font_table ||= Uniword::Wordprocessingml::FontTable.new
        package.web_settings ||= Uniword::Wordprocessingml::WebSettings.new
        package.to_file(path, validate: validate)
      end

      # Populate the allocator from all existing template data.
      # Must be called BEFORE any builder runs (populate-first principle).
      def populate_allocator
        @allocator = IdAllocator.populate_from_package(self)
      end

      # Guarantee the single rId authority before reconciliation: reuse
      # the package's allocator (loaded/builder-seeded) or start one,
      # then seed it from the package's current relationships. Seeding
      # preserves loaded rIds verbatim; earlier builder allocations keep
      # their ids — a seeded rel whose id collides is reallocated
      # deterministically (IdAllocator#seed_from_rels).
      def prepare_allocator
        self.allocator ||= IdAllocator.new
        allocator.seed_from_rels(package_rels&.relationships,
                                 scope: :package)
        allocator.seed_from_rels(document_rels&.relationships)
        allocator
      end

      # Save package to file
      #
      # @param path [String] Output file path
      # @param validate [Boolean, nil] Run the package integrity gate before
      #   writing; nil falls back to Uniword.configuration.validate_on_save
      # @return [void]
      # @raise [Uniword::ValidationError] when the gate is enabled and the
      #   generated package content is invalid
      def to_file(path, validate: nil)
        zip_content = to_zip_content(validate: validate)
        packager = Infrastructure::ZipPackager.new
        packager.package(zip_content, path)
      end

      # Generate ZIP content hash
      #
      # Runs the Reconciler (the only mutating pass), records its repair
      # report on #applied_fixes, and — unless validation is disabled —
      # refuses invalid output via the PackageIntegrityChecker gate.
      #
      # @param validate [Boolean, nil] Run the package integrity gate;
      #   nil falls back to Uniword.configuration.validate_on_save
      # @return [Hash] File paths => content
      # @raise [Uniword::ValidationError] when the gate is enabled and the
      #   generated package content is invalid
      def to_zip_content(validate: nil)
        content = {}

        self.content_types ||= self.class.minimal_content_types
        self.package_rels ||= self.class.minimal_package_rels
        self.document_rels ||= self.class.minimal_document_rels

        self.settings ||= Uniword::Wordprocessingml::Settings.new
        self.font_table ||= Uniword::Wordprocessingml::FontTable.new
        self.web_settings ||= Uniword::Wordprocessingml::WebSettings.new

        # An allocator carried into the save (builder-managed document
        # or loaded package) selects light-touch repairs; documents
        # without one get the full normalization repertoire. rIds flow
        # through the allocator either way.
        builder_managed = !allocator.nil?
        prepare_allocator

        reconciler = Reconciler.new(self,
                                    profile: profile || Profile.defaults,
                                    allocator: allocator,
                                    builder_managed: builder_managed)
        reconciler.reconcile
        @applied_fixes = reconciler.applied_fixes
        log_applied_fixes

        inject_part_relationships(content, content_types, package_rels, document_rels)
        serialize_package_parts(content, content_types, package_rels, document_rels)

        # OOXML requires [Content_Types].xml as the first ZIP entry.
        reorder_content_hash(content)

        enforce_package_integrity(content, validate)
        content
      end

      # Ensure [Content_Types].xml is first, _rels/.rels is second.
      def reorder_content_hash(content)
        priority = {}
        priority["[Content_Types].xml"] = content.delete("[Content_Types].xml") if content.key?("[Content_Types].xml")
        priority["_rels/.rels"] = content.delete("_rels/.rels") if content.key?("_rels/.rels")
        content.replace(priority.merge(content))
      end

      # Delegate common DocumentRoot methods for API compatibility

      def paragraphs
        document&.paragraphs || []
      end

      def tables
        document&.tables || []
      end

      def body
        document&.body
      end

      def text
        document&.text || ""
      end

      def each_paragraph(&)
        paragraphs.each(&)
      end

      alias save to_file

      def charts
        document&.charts || []
      end

      def styles_configuration
        document&.styles_configuration
      end

      private

      # Log each applied fix via Uniword.logger when policy allows.
      #
      # @return [void]
      def log_applied_fixes
        return if @applied_fixes.empty?
        return unless Uniword.configuration.log_save_fixes

        @applied_fixes.each do |fix|
          Uniword.logger&.info { "Reconciler fix #{fix}" }
        end
      end

      # Write-time integrity gate: refuse invalid package content.
      #
      # @param content [Hash] File paths => content
      # @param validate [Boolean, nil] explicit override; nil reads policy
      # @return [void]
      # @raise [Uniword::ValidationError] listing all integrity issues
      def enforce_package_integrity(content, validate)
        validate = Uniword.configuration.validate_on_save if validate.nil?
        return unless validate

        issues = PackageIntegrityChecker.new.check(content)
        return if issues.empty?

        raise Uniword::ValidationError.new(
          self,
          issues.map { |issue| "#{issue.code} (#{issue.part}): #{issue.message}" },
          issues: issues,
        )
      end
    end
  end
end
