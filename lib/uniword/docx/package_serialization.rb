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
        inject_headers(content_types, document_rels)
        inject_footers(content_types, document_rels)
        inject_header_footer_parts(content_types, document_rels)
        inject_notes(content_types, document_rels)
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
        if footnotes
          content["word/footnotes.xml"] =
            serialize_part(footnotes)
        end
        if endnotes
          content["word/endnotes.xml"] =
            serialize_part(endnotes)
        end

        # Bibliography sources
        if document&.bibliography_sources
          content["word/sources.xml"] =
            serialize_infrastructure(document.bibliography_sources)
        end

        # Headers and footers
        serialize_headers(content)
        serialize_footers(content)
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

      # Generate the next numeric relationship ID for a Relationships object.
      def next_rid(relationships)
        Ooxml::Relationships::PackageRelationships.next_available_rid(
          relationships,
        )
      end

      # Shared pattern: ensure a part has both a content type override and
      # a document relationship. Idempotent — skips if already present.
      # When allocator is present, only adds content type (rels handled by allocator).
      def ensure_content_type(content_types, rels, part_name:,
                              content_type:, rel_type:, target:)
        unless content_types.overrides.any? { |o| o.part_name == part_name }
          content_types.overrides << Uniword::ContentTypes::Override.new(
            part_name: part_name, content_type: content_type,
          )
        end

        return if allocator
        return if rels.relationships.any? { |r| r.target == target }

        rels.relationships << Ooxml::Relationships::Relationship.new(
          id: next_rid(rels), type: rel_type, target: target,
        )
      end

      # Legacy alias — calls ensure_content_type (same behavior)
      alias ensure_part_registered ensure_content_type

      def inject_image_parts(content, content_types, document_rels)
        return unless document&.image_parts && !document.image_parts.empty?

        document.image_parts.each_value do |image_data|
          ext = File.extname(image_data[:target]).delete(".")
          next if content_types.defaults.any? { |d| d.extension == ext }

          content_types.defaults << Uniword::ContentTypes::Default.new(
            extension: ext, content_type: image_data[:content_type],
          )
        end

        document.image_parts.each_value do |image_data|
          content["word/#{image_data[:target]}"] = image_data[:data]
        end

        return if allocator

        document.image_parts.each do |r_id, image_data|
          next if document_rels.relationships.any? { |r| r.target == image_data[:target] }

          document_rels.relationships << Ooxml::Relationships::Relationship.new(
            id: r_id,
            type: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/image",
            target: image_data[:target],
          )
        end
      end

      def inject_chart_parts(content, content_types, document_rels)
        return unless document&.chart_parts && !document.chart_parts.empty?

        unless content_types.overrides.any? do |o|
          o.part_name&.start_with?("/word/charts/")
        end
          content_types.overrides << Uniword::ContentTypes::Override.new(
            part_name: "/word/charts/chart1.xml",
            content_type: "application/vnd.openxmlformats-officedocument.drawingml.chart+xml",
          )
        end

        document.chart_parts.each do |r_id, chart_data|
          content["word/#{chart_data[:target]}"] = chart_data[:xml]
          document_rels.relationships << Ooxml::Relationships::Relationship.new(
            id: r_id,
            type: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/chart",
            target: chart_data[:target],
          )
        end
      end

      def inject_bibliography(content_types, document_rels)
        return unless document&.bibliography_sources

        ensure_content_type(content_types, document_rels,
                            part_name: "/word/sources.xml",
                            content_type: "application/vnd.openxmlformats-officedocument.bibliography+xml",
                            rel_type: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/bibliography",
                            target: "sources.xml")
      end

      def inject_custom_properties(content_types, package_rels)
        return unless custom_properties && !custom_properties.properties.empty?

        unless content_types.overrides.any? do |o|
          o.part_name == "/docProps/custom.xml"
        end
          content_types.overrides << Uniword::ContentTypes::Override.new(
            part_name: "/docProps/custom.xml",
            content_type: "application/vnd.openxmlformats-officedocument.custom-properties+xml",
          )
        end

        return if package_rels.relationships.any? do |r|
          r.type.to_s.include?("officeDocument/2006/relationships/custom-properties")
        end

        package_rels.relationships << Ooxml::Relationships::Relationship.new(
          id: next_rid(package_rels),
          type: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/custom-properties",
          target: "docProps/custom.xml",
        )
      end

      def inject_custom_xml(content_types)
        return unless custom_xml_items && !custom_xml_items.empty?

        custom_xml_items.each do |item|
          idx = item[:index]
          next if content_types.overrides.any? do |o|
            o.part_name == "/customXml/itemProps#{idx}.xml"
          end

          content_types.overrides << Uniword::ContentTypes::Override.new(
            part_name: "/customXml/itemProps#{idx}.xml",
            content_type: "application/vnd.openxmlformats-officedocument.customXmlProperties+xml",
          )
        end
      end

      def inject_headers(content_types, document_rels)
        return unless document&.headers && !document.headers.empty?

        counter = 0
        document.headers.each_key do |type|
          counter += 1
          target = "header#{counter}.xml"

          unless content_types.overrides.any? { |o| o.part_name == "/word/#{target}" }
            content_types.overrides << Uniword::ContentTypes::Override.new(
              part_name: "/word/#{target}",
              content_type: "application/vnd.openxmlformats-officedocument.wordprocessingml.header+xml",
            )
          end

          next if allocator
          next if document_rels.relationships.any? { |r| r.target == target }

          r_id = next_rid(document_rels)
          document_rels.relationships << Ooxml::Relationships::Relationship.new(
            id: r_id,
            type: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/header",
            target: target,
          )

          wire_header_reference(type, r_id)
        end
      end

      def inject_footers(content_types, document_rels)
        return unless document&.footers && !document.footers.empty?

        counter = 0
        document.footers.each_key do |type|
          counter += 1
          target = "footer#{counter}.xml"

          unless content_types.overrides.any? { |o| o.part_name == "/word/#{target}" }
            content_types.overrides << Uniword::ContentTypes::Override.new(
              part_name: "/word/#{target}",
              content_type: "application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml",
            )
          end

          next if allocator
          next if document_rels.relationships.any? { |r| r.target == target }

          r_id = next_rid(document_rels)
          document_rels.relationships << Ooxml::Relationships::Relationship.new(
            id: r_id,
            type: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer",
            target: target,
          )

          wire_footer_reference(type, r_id)
        end
      end

      def inject_header_footer_parts(content_types, document_rels)
        return unless document&.header_footer_parts && !document.header_footer_parts.empty?

        document.header_footer_parts.each do |part|
          part_name = "/word/#{part[:target]}"
          unless content_types.overrides.any? { |o| o.part_name == part_name }
            content_types.overrides << Uniword::ContentTypes::Override.new(
              part_name: part_name,
              content_type: part[:content_type],
            )
          end

          next if allocator
          next if document_rels.relationships.any? { |r| r.id == part[:r_id] }

          document_rels.relationships << Ooxml::Relationships::Relationship.new(
            id: part[:r_id],
            type: part[:rel_type],
            target: part[:target],
          )
        end
      end

      def inject_notes(content_types, document_rels)
        if footnotes
          ensure_content_type(content_types, document_rels,
                              part_name: "/word/footnotes.xml",
                              content_type: "application/vnd.openxmlformats-officedocument.wordprocessingml.footnotes+xml",
                              rel_type: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/footnotes",
                              target: "footnotes.xml")
        end

        return unless endnotes

        ensure_content_type(content_types, document_rels,
                            part_name: "/word/endnotes.xml",
                            content_type: "application/vnd.openxmlformats-officedocument.wordprocessingml.endnotes+xml",
                            rel_type: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/endnotes",
                            target: "endnotes.xml")
      end

      def inject_theme(content_types, document_rels)
        return unless theme

        ensure_content_type(content_types, document_rels,
                            part_name: "/word/theme/theme1.xml",
                            content_type: "application/vnd.openxmlformats-officedocument.theme+xml",
                            rel_type: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/theme",
                            target: "theme/theme1.xml")
      end

      def inject_numbering(content_types, document_rels)
        return unless numbering

        ensure_content_type(content_types, document_rels,
                            part_name: "/word/numbering.xml",
                            content_type: "application/vnd.openxmlformats-officedocument.wordprocessingml.numbering+xml",
                            rel_type: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/numbering",
                            target: "numbering.xml")
      end

      def inject_embeddings(content_types, document_rels)
        return unless embeddings && !embeddings.empty?

        embeddings.each_with_index do |(target, _data), idx|
          part_name = "/word/#{target}"
          next if content_types.overrides.any? { |o| o.part_name == part_name }

          content_types.overrides << Uniword::ContentTypes::Override.new(
            part_name: part_name,
            content_type: "application/vnd.openxmlformats-officedocument.oleObject",
          )

          next if document_rels.relationships.any? { |r| r.target == target }

          document_rels.relationships << Ooxml::Relationships::Relationship.new(
            id: "rIdEmbedding#{idx + 1}",
            type: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/oleObject",
            target: target,
          )
        end
      end

      def wire_header_reference(type, r_id)
        return unless document&.body

        sect_pr = document.body.section_properties ||= Wordprocessingml::SectionProperties.new
        existing = sect_pr.header_references&.find { |r| r.type == type }
        if existing
          existing.r_id = r_id
        else
          sect_pr.header_references << Wordprocessingml::HeaderReference.new(
            type: type, r_id: r_id,
          )
        end
      end

      def wire_footer_reference(type, r_id)
        return unless document&.body

        sect_pr = document.body.section_properties ||= Wordprocessingml::SectionProperties.new
        existing = sect_pr.footer_references&.find { |r| r.type == type }
        if existing
          existing.r_id = r_id
        else
          sect_pr.footer_references << Wordprocessingml::FooterReference.new(
            type: type, r_id: r_id,
          )
        end
      end

      def serialize_headers(content)
        return unless document&.headers && !document.headers.empty?

        idx = 0
        document.headers.each_value do |header_obj|
          idx += 1
          content["word/header#{idx}.xml"] =
            serialize_part(header_obj)
        end
      end

      def serialize_footers(content)
        return unless document&.footers && !document.footers.empty?

        idx = 0
        document.footers.each_value do |footer_obj|
          idx += 1
          content["word/footer#{idx}.xml"] =
            serialize_part(footer_obj)
        end
      end

      def serialize_header_footer_parts(content)
        return unless document&.header_footer_parts && !document.header_footer_parts.empty?

        document.header_footer_parts.each do |part|
          content["word/#{part[:target]}"] =
            serialize_part(part[:content])
        end
      end

      def serialize_embeddings(content)
        return unless embeddings && !embeddings.empty?

        embeddings.each do |target, data|
          content["word/#{target}"] = data
        end
      end
    end
  end
end
