# frozen_string_literal: true

module Uniword
  module Ooxml
    # Single source of truth for OOXML package part metadata.
    #
    # Maps every part kind the library reads or writes to its package
    # path, content type, relationship type, [Content_Types].xml entry
    # form (Default vs Override), loader strategy, and document/package
    # attributes. Content type and relationship type literals live ONLY
    # here; consumers (Uniword::ContentTypes, Docx::PackageDefaults,
    # Docx::Reconciler::PackageStructure, Docx::PartLoader,
    # DocumentFactory, and the Docx::PackageSerialization inject_*
    # methods) derive from this registry instead of holding their own
    # literals.
    #
    # Open/closed: a new part kind is added by registering a
    # PartDefinition — consumers need no further changes.
    #
    # @example Look up a part by key
    #   defn = PartRegistry.find_by_key(:styles)
    #   defn.part_name # => "/word/styles.xml"
    #   defn.rel_type  # => ".../relationships/styles"
    #
    # @example Register a custom part kind
    #   PartRegistry.register(
    #     PartDefinition.new(key: :glossary, path: "word/glossary/document.xml",
    #                        target: "glossary/document.xml",
    #                        content_type: "...document.glossary+xml",
    #                        rel_type: ".../glossaryDocument",
    #                        kind: :override, rels_scope: :document)
    #   )
    module PartRegistry
      # Relationship type base URIs. These literals appear only here.
      OFFICE_REL_BASE =
        "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
      PACKAGE_REL_BASE =
        "http://schemas.openxmlformats.org/package/2006/relationships"

      # Content type prefixes (literals appear only here).
      CT_OFFICE = "application/vnd.openxmlformats-officedocument"
      CT_WML = "#{CT_OFFICE}.wordprocessingml".freeze
      CT_PACKAGE = "application/vnd.openxmlformats-package"

      # Built-in registrations. Registration order is observable in
      # emitted output: the :standard entries reproduce the historic
      # ContentTypes.generate ordering exactly (defaults first —
      # jpeg, png, gif, rels, xml — then overrides in the historic
      # order). Non-standard parts follow; consumers select their own
      # ordered subsets by key.
      #
      # Loader metadata: +loader+ selects the Docx::PartLoader
      # strategy, +loader_model+ the parsing model class,
      # +load_priority+ orders the load (content types and package
      # rels first; the main document before the parts its rels
      # describe), and +document_attribute+/+package_attribute+ name
      # where the part lives on Wordprocessingml::DocumentRoot and
      # Docx::Package for the two registry-driven copy loops.
      BUILT_INS = [
        # -- Content-type Defaults (extension → content type) --
        { key: :jpeg, kind: :default, extension: "jpeg",
          content_type: "image/jpeg", standard: true },
        { key: :png, kind: :default, extension: "png",
          content_type: "image/png", standard: true },
        { key: :gif, kind: :default, extension: "gif",
          content_type: "image/gif", standard: true },
        { key: :rels, kind: :default, extension: "rels",
          content_type: "#{CT_PACKAGE}.relationships+xml",
          required: true, standard: true },
        { key: :xml, kind: :default, extension: "xml",
          content_type: "application/xml",
          required: true, standard: true },

        # -- Standard Override parts (historic generate order) --
        { key: :document, kind: :override, path: "word/document.xml",
          content_type: "#{CT_WML}.document.main+xml",
          rel_type: "#{OFFICE_REL_BASE}/officeDocument",
          required: true, standard: true, rels_scope: :package,
          loader: :xml_model,
          loader_model: Uniword::Wordprocessingml::DocumentRoot,
          path_resolution: :office_document, load_priority: 40,
          package_attribute: :document },
        { key: :numbering, kind: :override, path: "word/numbering.xml",
          target: "numbering.xml", content_type: "#{CT_WML}.numbering+xml",
          rel_type: "#{OFFICE_REL_BASE}/numbering",
          standard: true, rels_scope: :document,
          loader: :xml_model,
          loader_model: Uniword::Wordprocessingml::NumberingConfiguration,
          load_priority: 50,
          package_attribute: :numbering,
          document_attribute: :numbering_configuration,
          to_package_guard: :numbering_configuration_loaded? },
        { key: :styles, kind: :override, path: "word/styles.xml",
          target: "styles.xml", content_type: "#{CT_WML}.styles+xml",
          rel_type: "#{OFFICE_REL_BASE}/styles",
          required: true, standard: true, rels_scope: :document,
          loader: :xml_model,
          loader_model: Uniword::Wordprocessingml::StylesConfiguration,
          load_priority: 50,
          package_attribute: :styles,
          document_attribute: :styles_configuration },
        { key: :settings, kind: :override, path: "word/settings.xml",
          target: "settings.xml", content_type: "#{CT_WML}.settings+xml",
          rel_type: "#{OFFICE_REL_BASE}/settings",
          required: true, standard: true, rels_scope: :document,
          loader: :xml_model,
          loader_model: Uniword::Wordprocessingml::Settings,
          load_priority: 50,
          package_attribute: :settings, document_attribute: :settings },
        { key: :web_settings, kind: :override, path: "word/webSettings.xml",
          target: "webSettings.xml",
          content_type: "#{CT_WML}.webSettings+xml",
          rel_type: "#{OFFICE_REL_BASE}/webSettings",
          required: true, standard: true, rels_scope: :document,
          loader: :xml_model,
          loader_model: Uniword::Wordprocessingml::WebSettings,
          load_priority: 50,
          package_attribute: :web_settings,
          document_attribute: :web_settings },
        { key: :font_table, kind: :override, path: "word/fontTable.xml",
          target: "fontTable.xml",
          content_type: "#{CT_WML}.fontTable+xml",
          rel_type: "#{OFFICE_REL_BASE}/fontTable",
          required: true, standard: true, rels_scope: :document,
          loader: :xml_model,
          loader_model: Uniword::Wordprocessingml::FontTable,
          load_priority: 50,
          package_attribute: :font_table,
          document_attribute: :font_table },
        { key: :theme, kind: :override, path: "word/theme/theme1.xml",
          target: "theme/theme1.xml",
          content_type: "#{CT_OFFICE}.theme+xml",
          rel_type: "#{OFFICE_REL_BASE}/theme",
          standard: true, rels_scope: :document,
          loader: :xml_model, loader_model: Uniword::Drawingml::Theme,
          load_priority: 70,
          package_attribute: :theme, document_attribute: :theme },
        { key: :core_properties, kind: :override, path: "docProps/core.xml",
          content_type: "#{CT_PACKAGE}.core-properties+xml",
          rel_type: "#{PACKAGE_REL_BASE}/metadata/core-properties",
          required: true, standard: true, rels_scope: :package,
          loader: :xml_model, loader_model: CoreProperties,
          load_priority: 30,
          package_attribute: :core_properties,
          document_attribute: :core_properties },
        { key: :app_properties, kind: :override, path: "docProps/app.xml",
          content_type: "#{CT_OFFICE}.extended-properties+xml",
          rel_type: "#{OFFICE_REL_BASE}/extended-properties",
          required: true, standard: true, rels_scope: :package,
          loader: :xml_model, loader_model: AppProperties,
          load_priority: 30,
          package_attribute: :app_properties,
          document_attribute: :app_properties },

        # -- Optional document parts --
        { key: :footnotes, kind: :override, path: "word/footnotes.xml",
          target: "footnotes.xml",
          content_type: "#{CT_WML}.footnotes+xml",
          rel_type: "#{OFFICE_REL_BASE}/footnotes",
          rels_scope: :document,
          loader: :xml_model,
          loader_model: Uniword::Wordprocessingml::Footnotes,
          load_priority: 80,
          package_attribute: :footnotes, document_attribute: :footnotes },
        { key: :endnotes, kind: :override, path: "word/endnotes.xml",
          target: "endnotes.xml",
          content_type: "#{CT_WML}.endnotes+xml",
          rel_type: "#{OFFICE_REL_BASE}/endnotes",
          rels_scope: :document,
          loader: :xml_model,
          loader_model: Uniword::Wordprocessingml::Endnotes,
          load_priority: 80,
          package_attribute: :endnotes, document_attribute: :endnotes },
        { key: :comments, kind: :override, path: "word/comments.xml",
          target: "comments.xml",
          content_type: "#{CT_WML}.comments+xml",
          rel_type: "#{OFFICE_REL_BASE}/comments",
          rels_scope: :document,
          loader: :xml_model, loader_model: Uniword::CommentsPart,
          load_priority: 80,
          package_attribute: :comments, document_attribute: :comments,
          to_package_type: Uniword::CommentsPart },
        # Bibliography sources are write-only: nothing reads
        # word/sources.xml back, so there is no loader and no
        # package→document copy.
        { key: :bibliography, kind: :override, path: "word/sources.xml",
          target: "sources.xml",
          content_type: "#{CT_OFFICE}.bibliography+xml",
          rel_type: "#{OFFICE_REL_BASE}/bibliography",
          rels_scope: :document,
          package_attribute: :bibliography_sources,
          document_attribute: :bibliography_sources,
          copy_to_document: false },
        { key: :header, kind: :override,
          path_pattern: "word/header%<counter>d.xml",
          target_pattern: "header%<counter>d.xml",
          content_type: "#{CT_WML}.header+xml",
          rel_type: "#{OFFICE_REL_BASE}/header",
          rels_scope: :document,
          loader: :header_footer,
          loader_model: Uniword::Wordprocessingml::Header,
          load_priority: 90 },
        { key: :footer, kind: :override,
          path_pattern: "word/footer%<counter>d.xml",
          target_pattern: "footer%<counter>d.xml",
          content_type: "#{CT_WML}.footer+xml",
          rel_type: "#{OFFICE_REL_BASE}/footer",
          rels_scope: :document,
          loader: :header_footer,
          loader_model: Uniword::Wordprocessingml::Footer,
          load_priority: 90 },
        { key: :custom_properties, kind: :override,
          path: "docProps/custom.xml",
          content_type: "#{CT_OFFICE}.custom-properties+xml",
          rel_type: "#{OFFICE_REL_BASE}/custom-properties",
          rels_scope: :package,
          loader: :xml_model, loader_model: CustomProperties,
          load_priority: 30,
          package_attribute: :custom_properties,
          document_attribute: :custom_properties },
        # The chart loader keys parts by document relationship id, so
        # they land directly on the document; no package→document copy.
        { key: :chart, kind: :override,
          path_pattern: "word/charts/chart%<n>d.xml",
          target_pattern: "charts/chart%<n>d.xml",
          content_type: "#{CT_OFFICE}.drawingml.chart+xml",
          rel_type: "#{OFFICE_REL_BASE}/chart",
          rels_scope: :document,
          loader: :chart, load_priority: 100,
          package_attribute: :chart_parts,
          document_attribute: :chart_parts,
          copy_to_document: false },
        # Images carry a per-extension Default content type resolved
        # from the image data at save time, so content_type is nil.
        { key: :image, kind: :default,
          path_pattern: "word/media/%<name>s",
          target_pattern: "media/%<name>s",
          rel_type: "#{OFFICE_REL_BASE}/image",
          rels_scope: :document,
          loader: :image, load_priority: 110 },
        # The embedding loader keys parts by target on the package's
        # embeddings collection; no package→document copy.
        { key: :ole_object, kind: :override,
          path_pattern: "word/embeddings/%<name>s",
          target_pattern: "embeddings/%<name>s",
          content_type: "#{CT_OFFICE}.oleObject",
          rel_type: "#{OFFICE_REL_BASE}/oleObject",
          rels_scope: :document,
          loader: :embedding, load_priority: 120,
          package_attribute: :embeddings,
          document_attribute: :embeddings,
          copy_to_document: false },
        # customXml items themselves fall under the "xml" Default;
        # only their itemProps parts get an Override. The :custom_xml
        # loader also pulls each item's itemProps and .rels sidecars.
        { key: :custom_xml_item, kind: :none,
          path_pattern: "customXml/item%<index>d.xml",
          loader: :custom_xml, load_priority: 30,
          package_attribute: :custom_xml_items,
          document_attribute: :custom_xml_items },
        { key: :custom_xml_item_props, kind: :override,
          path_pattern: "customXml/itemProps%<index>d.xml",
          content_type: "#{CT_OFFICE}.customXmlProperties+xml" },
        # Hyperlink relationships target external URLs; no part, no
        # content type.
        { key: :hyperlink, kind: :none,
          rel_type: "#{OFFICE_REL_BASE}/hyperlink",
          rels_scope: :document },
        # Theme part of THMX (theme) packages, rooted at /theme.
        { key: :thmx_theme, kind: :override, path: "theme/theme1.xml",
          content_type: "#{CT_OFFICE}.theme+xml", required: true },

        # -- Read-side infrastructure parts (no content-type entry
        #    of their own; kind :none keeps emission untouched) --
        { key: :content_types, kind: :none, path: "[Content_Types].xml",
          loader: :xml_model, loader_model: Uniword::ContentTypes::Types,
          load_priority: 10,
          package_attribute: :content_types,
          document_attribute: :content_types },
        { key: :package_rels, kind: :none, path: "_rels/.rels",
          loader: :xml_model,
          loader_model: Relationships::PackageRelationships,
          load_priority: 20,
          package_attribute: :package_rels,
          document_attribute: :package_rels },
        { key: :document_rels, kind: :none,
          path: "word/_rels/document.xml.rels",
          loader: :xml_model,
          loader_model: Relationships::PackageRelationships,
          path_resolution: :office_document_rels, load_priority: 60,
          package_attribute: :document_rels,
          document_attribute: :document_rels },
        { key: :settings_rels, kind: :none,
          path: "word/_rels/settings.xml.rels",
          loader: :xml_model,
          loader_model: Relationships::PackageRelationships,
          load_priority: 50,
          package_attribute: :settings_rels,
          document_attribute: :settings_rels },
        { key: :theme_rels, kind: :none,
          path: "word/theme/_rels/theme1.xml.rels",
          loader: :xml_model,
          loader_model: Relationships::PackageRelationships,
          load_priority: 75,
          package_attribute: :theme_rels,
          document_attribute: :theme_rels },
        { key: :footnotes_rels, kind: :none,
          path: "word/_rels/footnotes.xml.rels",
          loader: :xml_model,
          loader_model: Relationships::PackageRelationships,
          load_priority: 85,
          package_attribute: :footnotes_rels,
          document_attribute: :footnotes_rels },
        { key: :endnotes_rels, kind: :none,
          path: "word/_rels/endnotes.xml.rels",
          loader: :xml_model,
          loader_model: Relationships::PackageRelationships,
          load_priority: 85,
          package_attribute: :endnotes_rels,
          document_attribute: :endnotes_rels },
        # Theme media files live on the theme's media_files, not on a
        # package/document attribute; loads only when a theme part was
        # parsed (see PartLoader::ThemeMediaLoader).
        { key: :theme_media, kind: :none,
          path_pattern: "word/theme/media/%<name>s",
          loader: :theme_media, load_priority: 72 },
      ].freeze

      class << self
        # Register a part definition. Re-registering an existing key
        # replaces it in place (preserving position); new keys append.
        #
        # @param definition [PartDefinition] definition to register
        # @return [PartDefinition] the registered definition
        # @raise [ArgumentError] when not given a PartDefinition
        def register(definition)
          unless definition.is_a?(PartDefinition)
            raise ArgumentError,
                  "expected PartDefinition, got #{definition.class}"
          end

          index = definitions.index { |d| d.key == definition.key }
          if index
            definitions[index] = definition
          else
            definitions << definition
          end
          definition
        end

        # Remove a registered definition (primarily for tests).
        #
        # @param key [Symbol] registry key
        # @return [Array<PartDefinition>, nil] the definitions list if
        #   a definition was removed, nil when the key was absent
        def unregister(key)
          definitions.reject! { |d| d.key == key.to_sym }
        end

        # @return [Array<PartDefinition>] all definitions, in
        #   registration order (a copy; safe to mutate)
        def all
          definitions.dup
        end

        # @param key [Symbol] registry key (e.g. :styles)
        # @return [PartDefinition, nil]
        def find_by_key(key)
          definitions.find { |d| d.key == key.to_sym }
        end

        # Find by package path; accepts both "word/styles.xml" and
        # "/word/styles.xml" forms, and matches numbered paths against
        # registered patterns ("word/header2.xml" → :header).
        #
        # @param path [String] package-relative path
        # @return [PartDefinition, nil]
        def find_by_path(path)
          normalized = path.to_s.delete_prefix("/")
          definitions.find { |d| path_match?(d, normalized) }
        end

        # @param content_type [String] MIME content type
        # @return [PartDefinition, nil] first definition with this type
        def find_by_content_type(content_type)
          definitions.find { |d| d.content_type == content_type }
        end

        # Find an Override definition by content-type part name.
        #
        # @param part_name [String] e.g. "/word/styles.xml"
        # @return [PartDefinition, nil]
        def override_for(part_name)
          normalized = part_name.to_s.delete_prefix("/")
          definitions.find do |d|
            d.override? && path_match?(d, normalized)
          end
        end

        # Find a Default definition by file extension.
        #
        # @param extension [String] e.g. "png"
        # @return [PartDefinition, nil]
        def default_for(extension)
          definitions.find do |d|
            d.default? && d.extension == extension.to_s
          end
        end

        # Definitions included in the comprehensive [Content_Types].xml
        # that ContentTypes.generate emits for new DOCX packages.
        #
        # @return [Array<PartDefinition>] in registration order
        def standard_defaults
          definitions.select { |d| d.standard? && d.default? }
        end

        # @return [Array<PartDefinition>] in registration order
        def standard_overrides
          definitions.select { |d| d.standard? && d.override? }
        end

        # Relationship type URIs whose relationships belong in the
        # package-level _rels/.rels part.
        #
        # @return [Array<String>] in registration order
        def package_rel_types
          definitions.filter_map { |d| d.rel_type if d.package_rel? }
        end

        # Definitions loadable from extracted ZIP content, in load
        # order: ascending PartDefinition#load_priority, registration
        # order within a priority (explicit index tiebreak — Ruby's
        # sort_by is not stable).
        #
        # @return [Array<PartDefinition>]
        def loadable
          definitions.select(&:loadable?).each_with_index
            .sort_by { |d, i| [d.load_priority || 100, i] }
            .map(&:first)
        end

        # Definitions mirrored package→document by
        # DocumentFactory.copy_package_parts_to_document.
        #
        # @return [Array<PartDefinition>] in registration order
        def copied_to_document
          definitions.select do |d|
            d.document_attribute && d.package_attribute &&
              d.copy_to_document?
          end
        end

        # Definitions mirrored document→package by
        # Docx::PackageDefaults.copy_document_parts_to_package.
        #
        # @return [Array<PartDefinition>] in registration order
        def copied_to_package
          definitions.select { |d| d.document_attribute && d.package_attribute }
        end

        private

        def definitions
          @definitions ||= []
        end

        def path_match?(definition, normalized_path)
          definition.match_path?(normalized_path)
        end
      end

      BUILT_INS.each { |attrs| register(PartDefinition.new(**attrs)) }
    end
  end
end
