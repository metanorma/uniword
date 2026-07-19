# frozen_string_literal: true

module Uniword
  module Docx
    # Content type injection and XML serialization for DOCX package parts.
    #
    # Handles the pre-serialization phase (injecting relationships and content
    # types) and the serialization phase (converting model objects to XML).
    #
    # Extracted from Package for separation of responsibilities.
    # Included in Package for backward compatibility.
    #
    # @api private
    module PackageSerialization
      DOCX_XML_OPTIONS = {
        encoding: "UTF-8",
        indent: 0,
        line_ending: "\r\n",
      }.freeze

      DOCX_PART_OPTIONS = {
        **DOCX_XML_OPTIONS,
        prefix: true,
        standalone: true,
      }.freeze

      DOCX_INFRA_OPTIONS = {
        **DOCX_XML_OPTIONS,
        declaration: true,
        standalone: true,
      }.freeze

      DOCX_PROPS_OPTIONS = {
        **DOCX_XML_OPTIONS,
        prefix: false,
        standalone: true,
      }.freeze

      # Inject content types and relationships for all package parts
      def inject_part_relationships(content, content_types, package_rels,
document_rels)
        inject_image_parts(content, content_types, document_rels)
        inject_chart_parts(content, content_types, document_rels)
        inject_bibliography(content_types, document_rels)
        inject_custom_properties(content_types, package_rels)
        inject_custom_xml(content_types)
        inject_header_footer_content_types(content_types)
        inject_notes(content_types, document_rels)
        inject_comments(content_types, document_rels)
        inject_theme(content_types, document_rels)
        inject_numbering(content_types, document_rels)
        inject_embeddings(content_types, document_rels)
      end

      # Serialize all package parts to XML and add to content hash
      def serialize_package_parts(content, content_types, package_rels,
document_rels)
        # Package infrastructure
        content["[Content_Types].xml"] =
          serialize_infrastructure(content_types)
        content["_rels/.rels"] =
          serialize_infrastructure(package_rels)

        # Document properties
        if core_properties
          content["docProps/core.xml"] =
            serialize_part(core_properties)
        end
        if app_properties
          content["docProps/app.xml"] =
            add_standalone(app_properties.to_xml(DOCX_PROPS_OPTIONS.dup))
        end
        if custom_properties
          content["docProps/custom.xml"] =
            add_standalone(custom_properties.to_xml(DOCX_PROPS_OPTIONS.dup))
        end

        # Custom XML data items
        if custom_xml_items && !custom_xml_items.empty?
          custom_xml_items.each do |item|
            idx = item[:index]
            content["customXml/item#{idx}.xml"] = item[:xml_content]
            if item[:props_xml]
              content["customXml/itemProps#{idx}.xml"] =
                item[:props_xml]
            end
            if item[:rels_xml]
              content["customXml/_rels/item#{idx}.xml.rels"] =
                item[:rels_xml]
            end
          end
        end

        # Document parts
        if document
          content["word/document.xml"] =
            serialize_part(document)
        end
        if styles
          content["word/styles.xml"] =
            serialize_part(styles)
        end
        if numbering
          content["word/numbering.xml"] =
            serialize_part(numbering)
        end
        if settings
          content["word/settings.xml"] =
            serialize_part(settings)
        end
        if settings_rels
          content["word/_rels/settings.xml.rels"] =
            serialize_infrastructure(settings_rels)
        end
        if font_table
          content["word/fontTable.xml"] =
            serialize_part(font_table)
        end
        if web_settings
          content["word/webSettings.xml"] =
            serialize_part(web_settings)
        end
        if document_rels
          content["word/_rels/document.xml.rels"] =
            serialize_infrastructure(document_rels)
        end

        # Theme
        if theme
          content["word/theme/theme1.xml"] =
            serialize_part(theme)
        end
        if theme_rels
          content["word/theme/_rels/theme1.xml.rels"] =
            serialize_infrastructure(theme_rels)
        end

        # Notes
        serialize_notes(content)

        # Comments
        if comments
          content["word/comments.xml"] =
            serialize_part(comments)
        end

        # Bibliography sources
        if document&.bibliography_sources
          content["word/sources.xml"] =
            serialize_infrastructure(document.bibliography_sources)
        end

        # Headers and footers (unified store)
        serialize_header_footer_parts(content)

        # OLE/embedded object binaries
        serialize_embeddings(content)
      end

      # Serialize an OOXML document part with standard encoding, single-line output.
      # All DOCX parts require standalone="yes" in the XML declaration for Word compatibility.
      def serialize_part(model)
        add_standalone(model.to_xml(DOCX_PART_OPTIONS.dup))
      end

      # Serialize package infrastructure (rels, content types) with declaration, single-line output
      def serialize_infrastructure(model)
        add_standalone(model.to_xml(DOCX_INFRA_OPTIONS.dup))
      end

      # Ensure the XML declaration includes standalone="yes".
      # lutaml-model omits this by default; Word's strict OPC validation requires it.
      def add_standalone(xml)
        xml.sub(
          %r{<\?xml version="1.0" encoding="UTF-8"\?>},
          '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>',
        )
      end

      private

      # Shared pattern: ensure a part has a content type override.
      # Idempotent — skips if already present. Relationships are owned
      # by the Reconciler (assembled from the IdAllocator), never by
      # the serializer. Part metadata comes from Ooxml::PartRegistry.
      def ensure_content_type(content_types, definition)
        part_name = definition.part_name
        return if content_types.overrides.any? { |o| o.part_name == part_name }

        content_types.overrides << Uniword::ContentTypes::Override.new(
          part_name: part_name, content_type: definition.content_type,
        )
      end

      # Legacy alias — calls ensure_content_type (same behavior)
      alias ensure_part_registered ensure_content_type

      def inject_image_parts(content, content_types, _document_rels)
        return unless document&.image_parts && !document.image_parts.empty?

        document.image_parts.each_value do |part|
          ext = File.extname(part.target.to_s).delete(".")
          next if content_types.defaults.any? { |d| d.extension == ext }

          content_types.defaults << Uniword::ContentTypes::Default.new(
            extension: ext, content_type: part.content_type,
          )
        end

        document.image_parts.each_value do |part|
          content["word/#{part.target}"] = part.data
        end
      end

      def inject_chart_parts(content, content_types, _document_rels)
        return unless document&.chart_parts && !document.chart_parts.empty?

        chart = Ooxml::PartRegistry.find_by_key(:chart)
        unless content_types.overrides.any? do |o|
          o.part_name&.start_with?("/word/charts/")
        end
          content_types.overrides << Uniword::ContentTypes::Override.new(
            part_name: chart.part_name_for(n: 1),
            content_type: chart.content_type,
          )
        end

        document.chart_parts.each_value do |part|
          content["word/#{part.target}"] = part.xml
        end
      end

      def inject_bibliography(content_types, _document_rels)
        return unless document&.bibliography_sources

        ensure_content_type(content_types,
                            Ooxml::PartRegistry.find_by_key(:bibliography))
      end

      def inject_custom_properties(content_types, package_rels)
        return unless custom_properties && !custom_properties.properties.empty?

        definition = Ooxml::PartRegistry.find_by_key(:custom_properties)
        unless content_types.overrides.any? do |o|
          o.part_name == definition.part_name
        end
          content_types.overrides << Uniword::ContentTypes::Override.new(
            part_name: definition.part_name,
            content_type: definition.content_type,
          )
        end

        return if package_rels.relationships.any? do |r|
          r.type.to_s.include?(definition.rel_type)
        end

        # The reconciler runs before injection; register the rId with
        # the allocator (single authority) and append the rel here.
        package_rels.relationships << Ooxml::Relationships::Relationship.new(
          id: allocator.alloc_rid(target: definition.target,
                                  type: definition.rel_type,
                                  scope: :package),
          type: definition.rel_type,
          target: definition.target,
        )
      end

      def inject_custom_xml(content_types)
        return unless custom_xml_items && !custom_xml_items.empty?

        props = Ooxml::PartRegistry.find_by_key(:custom_xml_item_props)
        custom_xml_items.each do |item|
          idx = item[:index]
          part_name = props.part_name_for(index: idx)
          next if content_types.overrides.any? do |o|
            o.part_name == part_name
          end

          content_types.overrides << Uniword::ContentTypes::Override.new(
            part_name: part_name,
            content_type: props.content_type,
          )
        end
      end

      # Register content-type overrides for every header/footer part in
      # the unified store. Relationships and sectPr references are owned
      # by the Reconciler (single wiring implementation); the serializer
      # only ensures each emitted part has exactly one override.
      def inject_header_footer_content_types(content_types)
        parts = document&.header_footer_parts
        return unless parts && !parts.empty?

        parts.each do |part|
          next unless part.target

          part_name = "/word/#{part.target}"
          next if content_types.overrides.any? { |o| o.part_name == part_name }

          content_types.overrides << Uniword::ContentTypes::Override.new(
            part_name: part_name, content_type: part.content_type,
          )
        end
      end

      def inject_notes(content_types, _document_rels)
        if footnotes
          ensure_content_type(content_types,
                              Ooxml::PartRegistry.find_by_key(:footnotes))
        end

        return unless endnotes

        ensure_content_type(content_types,
                            Ooxml::PartRegistry.find_by_key(:endnotes))
      end

      def inject_theme(content_types, _document_rels)
        return unless theme

        ensure_content_type(content_types,
                            Ooxml::PartRegistry.find_by_key(:theme))
      end

      def inject_comments(content_types, _document_rels)
        return unless comments

        ensure_content_type(content_types,
                            Ooxml::PartRegistry.find_by_key(:comments))
      end

      def inject_numbering(content_types, _document_rels)
        return unless numbering

        ensure_content_type(content_types,
                            Ooxml::PartRegistry.find_by_key(:numbering))
      end

      def inject_embeddings(content_types, _document_rels)
        return unless embeddings && !embeddings.empty?

        ole = Ooxml::PartRegistry.find_by_key(:ole_object)
        embeddings.each_key do |target|
          part_name = "/word/#{target}"
          next if content_types.overrides.any? { |o| o.part_name == part_name }

          content_types.overrides << Uniword::ContentTypes::Override.new(
            part_name: part_name,
            content_type: ole.content_type,
          )
        end
      end

      def serialize_notes(content)
        if footnotes
          content["word/footnotes.xml"] =
            serialize_part(footnotes)
        end
        if endnotes
          content["word/endnotes.xml"] =
            serialize_part(endnotes)
        end
        if footnotes_rels
          content["word/_rels/footnotes.xml.rels"] =
            serialize_infrastructure(footnotes_rels)
        end
        if endnotes_rels
          content["word/_rels/endnotes.xml.rels"] =
            serialize_infrastructure(endnotes_rels)
        end
      end

      # Emit every header/footer part from the unified store: one part
      # file per part, headers before footers (historic emission order).
      def serialize_header_footer_parts(content)
        parts = document&.header_footer_parts
        return unless parts && !parts.empty?

        (parts.of_kind(:header) + parts.of_kind(:footer)).each do |part|
          next unless part.target && part.content

          content["word/#{part.target}"] =
            serialize_part(part.serializable_content)
        end
      end

      def serialize_embeddings(content)
        return unless embeddings && !embeddings.empty?

        embeddings.each do |target, part|
          content["word/#{target}"] = part.content
        end
      end
    end
  end
end
