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
      # Inject content types and relationships for all package parts
      def inject_part_relationships(content, content_types, package_rels, document_rels)
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
      end

      # Serialize all package parts to XML and add to content hash
      def serialize_package_parts(content, content_types, package_rels, document_rels)
        # Package infrastructure
        content["[Content_Types].xml"] = content_types.to_xml(encoding: "UTF-8", declaration: true)
        content["_rels/.rels"] = package_rels.to_xml(encoding: "UTF-8", declaration: true)

        # Document properties
        content["docProps/core.xml"] = core_properties.to_xml(encoding: "UTF-8", prefix: true) if core_properties
        content["docProps/app.xml"] = app_properties.to_xml(encoding: "UTF-8", prefix: false) if app_properties
        content["docProps/custom.xml"] = custom_properties.to_xml(encoding: "UTF-8", prefix: false) if custom_properties

        # Custom XML data items
        if custom_xml_items && !custom_xml_items.empty?
          custom_xml_items.each do |item|
            idx = item[:index]
            content["customXml/item#{idx}.xml"] = item[:xml_content]
            content["customXml/itemProps#{idx}.xml"] = item[:props_xml] if item[:props_xml]
            content["customXml/_rels/item#{idx}.xml.rels"] = item[:rels_xml] if item[:rels_xml]
          end
        end

        # Document parts
        content["word/document.xml"] = document.to_xml(encoding: "UTF-8", prefix: true, fix_boolean_elements: true) if document
        if styles
          content["word/styles.xml"] =
            styles.to_xml(encoding: "UTF-8", prefix: true, fix_boolean_elements: true)
        end
        if numbering
          content["word/numbering.xml"] =
            numbering.to_xml(encoding: "UTF-8", prefix: true, fix_boolean_elements: true)
        end
        content["word/settings.xml"] = settings.to_xml(encoding: "UTF-8", prefix: true) if settings
        content["word/fontTable.xml"] = font_table.to_xml(encoding: "UTF-8", prefix: true) if font_table
        content["word/webSettings.xml"] = web_settings.to_xml(encoding: "UTF-8", prefix: true) if web_settings
        if document_rels
          content["word/_rels/document.xml.rels"] =
            document_rels.to_xml(encoding: "UTF-8", declaration: true)
        end

        # Theme
        content["word/theme/theme1.xml"] = theme.to_xml(encoding: "UTF-8", prefix: true) if theme
        if theme_rels
          content["word/theme/_rels/theme1.xml.rels"] =
            theme_rels.to_xml(encoding: "UTF-8", declaration: true)
        end

        # Notes
        if footnotes
          content["word/footnotes.xml"] =
            footnotes.to_xml(encoding: "UTF-8", prefix: true, fix_boolean_elements: true)
        end
        if endnotes
          content["word/endnotes.xml"] =
            endnotes.to_xml(encoding: "UTF-8", prefix: true, fix_boolean_elements: true)
        end

        # Bibliography sources
        content["word/sources.xml"] = document.bibliography_sources.to_xml(encoding: "UTF-8", declaration: true) if document&.bibliography_sources

        # Headers and footers
        serialize_headers(content)
        serialize_footers(content)
        serialize_header_footer_parts(content)
      end

      private

      def inject_image_parts(content, content_types, document_rels)
        return unless document&.image_parts && !document.image_parts.empty?

        document.image_parts.each_value do |image_data|
          ext = File.extname(image_data[:target]).delete(".")
          next if content_types.defaults.any? { |d| d.extension == ext }

          content_types.defaults << Uniword::ContentTypes::Default.new(
            extension: ext, content_type: image_data[:content_type]
          )
        end

        document.image_parts.each do |r_id, image_data|
          content["word/#{image_data[:target]}"] = image_data[:data]
          document_rels.relationships << Ooxml::Relationships::Relationship.new(
            id: r_id,
            type: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/image",
            target: image_data[:target]
          )
        end
      end

      def inject_chart_parts(content, content_types, document_rels)
        return unless document&.chart_parts && !document.chart_parts.empty?

        unless content_types.overrides.any? { |o| o.part_name&.start_with?("/word/charts/") }
          content_types.overrides << Uniword::ContentTypes::Override.new(
            part_name: "/word/charts/chart1.xml",
            content_type: "application/vnd.openxmlformats-officedocument.drawingml.chart+xml"
          )
        end

        document.chart_parts.each do |r_id, chart_data|
          content["word/#{chart_data[:target]}"] = chart_data[:xml]
          document_rels.relationships << Ooxml::Relationships::Relationship.new(
            id: r_id,
            type: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/chart",
            target: chart_data[:target]
          )
        end
      end

      def inject_bibliography(content_types, document_rels)
        return unless document&.bibliography_sources

        unless content_types.overrides.any? { |o| o.part_name == "/word/sources.xml" }
          content_types.overrides << Uniword::ContentTypes::Override.new(
            part_name: "/word/sources.xml",
            content_type: "application/vnd.openxmlformats-officedocument.bibliography+xml"
          )
        end

        return if document_rels.relationships.any? { |r| r.target == "sources.xml" }

        document_rels.relationships << Ooxml::Relationships::Relationship.new(
          id: "rIdSrc#{SecureRandom.hex(4)}",
          type: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/bibliography",
          target: "sources.xml"
        )
      end

      def inject_custom_properties(content_types, package_rels)
        return unless custom_properties && !custom_properties.properties.empty?

        unless content_types.overrides.any? { |o| o.part_name == "/docProps/custom.xml" }
          content_types.overrides << Uniword::ContentTypes::Override.new(
            part_name: "/docProps/custom.xml",
            content_type: "application/vnd.openxmlformats-officedocument.custom-properties+xml"
          )
        end

        unless package_rels.relationships.any? do |r|
          r.type.to_s.include?("officeDocument/2006/relationships/custom-properties")
        end
          package_rels.relationships << Ooxml::Relationships::Relationship.new(
            id: "rIdCustProps",
            type: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/custom-properties",
            target: "docProps/custom.xml"
          )
        end
      end

      def inject_custom_xml(content_types)
        return unless custom_xml_items && !custom_xml_items.empty?

        custom_xml_items.each do |item|
          idx = item[:index]
          next if content_types.overrides.any? { |o| o.part_name == "/customXml/itemProps#{idx}.xml" }

          content_types.overrides << Uniword::ContentTypes::Override.new(
            part_name: "/customXml/itemProps#{idx}.xml",
            content_type: "application/vnd.openxmlformats-officedocument.customXmlProperties+xml"
          )
        end
      end

      def inject_headers(content_types, document_rels)
        return unless document&.headers && !document.headers.empty?

        counter = 0
        document.headers.each_key do |type|
          counter += 1
          r_id = "rIdHeader#{counter}"

          content_types.overrides << Uniword::ContentTypes::Override.new(
            part_name: "/word/header#{counter}.xml",
            content_type: "application/vnd.openxmlformats-officedocument.wordprocessingml.header+xml"
          )

          document_rels.relationships << Ooxml::Relationships::Relationship.new(
            id: r_id,
            type: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/header",
            target: "header#{counter}.xml"
          )

          wire_header_reference(type, r_id)
        end
      end

      def inject_footers(content_types, document_rels)
        return unless document&.footers && !document.footers.empty?

        counter = 0
        document.footers.each_key do |type|
          counter += 1
          r_id = "rIdFooter#{counter}"

          content_types.overrides << Uniword::ContentTypes::Override.new(
            part_name: "/word/footer#{counter}.xml",
            content_type: "application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml"
          )

          document_rels.relationships << Ooxml::Relationships::Relationship.new(
            id: r_id,
            type: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer",
            target: "footer#{counter}.xml"
          )

          wire_footer_reference(type, r_id)
        end
      end

      def inject_header_footer_parts(content_types, document_rels)
        return unless document&.header_footer_parts && !document.header_footer_parts.empty?

        document.header_footer_parts.each do |part|
          content_types.overrides << Uniword::ContentTypes::Override.new(
            part_name: "/word/#{part[:target]}",
            content_type: part[:content_type]
          )

          document_rels.relationships << Ooxml::Relationships::Relationship.new(
            id: part[:r_id],
            type: part[:rel_type],
            target: part[:target]
          )
        end
      end

      def inject_notes(content_types, document_rels)
        if footnotes
          unless content_types.overrides.any? { |o| o.part_name == "/word/footnotes.xml" }
            content_types.overrides << Uniword::ContentTypes::Override.new(
              part_name: "/word/footnotes.xml",
              content_type: "application/vnd.openxmlformats-officedocument.wordprocessingml.footnotes+xml"
            )
          end

          unless document_rels.relationships.any? { |r| r.target == "footnotes.xml" }
            document_rels.relationships << Ooxml::Relationships::Relationship.new(
              id: "rIdFootnotes",
              type: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/footnotes",
              target: "footnotes.xml"
            )
          end
        end

        return unless endnotes

        unless content_types.overrides.any? { |o| o.part_name == "/word/endnotes.xml" }
          content_types.overrides << Uniword::ContentTypes::Override.new(
            part_name: "/word/endnotes.xml",
            content_type: "application/vnd.openxmlformats-officedocument.wordprocessingml.endnotes+xml"
          )
        end

        return if document_rels.relationships.any? { |r| r.target == "endnotes.xml" }

        document_rels.relationships << Ooxml::Relationships::Relationship.new(
          id: "rIdEndnotes",
          type: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/endnotes",
          target: "endnotes.xml"
        )
      end

      def inject_theme(content_types, document_rels)
        return unless theme

        unless content_types.overrides.any? { |o| o.part_name == "/word/theme/theme1.xml" }
          content_types.overrides << Uniword::ContentTypes::Override.new(
            part_name: "/word/theme/theme1.xml",
            content_type: "application/vnd.openxmlformats-officedocument.theme+xml"
          )
        end

        return if document_rels.relationships.any? { |r| r.target == "theme/theme1.xml" }

        document_rels.relationships << Ooxml::Relationships::Relationship.new(
          id: "rIdTheme",
          type: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/theme",
          target: "theme/theme1.xml"
        )
      end

      def inject_numbering(content_types, document_rels)
        return unless numbering

        unless content_types.overrides.any? { |o| o.part_name == "/word/numbering.xml" }
          content_types.overrides << Uniword::ContentTypes::Override.new(
            part_name: "/word/numbering.xml",
            content_type: "application/vnd.openxmlformats-officedocument.wordprocessingml.numbering+xml"
          )
        end

        return if document_rels.relationships.any? { |r| r.target == "numbering.xml" }

        document_rels.relationships << Ooxml::Relationships::Relationship.new(
          id: "rIdNumbering",
          type: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/numbering",
          target: "numbering.xml"
        )
      end

      def wire_header_reference(type, r_id)
        return unless document&.body

        sect_pr = document.body.section_properties ||= Wordprocessingml::SectionProperties.new
        existing = sect_pr.header_references&.find { |r| r.type == type }
        if existing
          existing.r_id = r_id
        else
          sect_pr.header_references << Wordprocessingml::HeaderReference.new(type: type, r_id: r_id)
        end
      end

      def wire_footer_reference(type, r_id)
        return unless document&.body

        sect_pr = document.body.section_properties ||= Wordprocessingml::SectionProperties.new
        existing = sect_pr.footer_references&.find { |r| r.type == type }
        if existing
          existing.r_id = r_id
        else
          sect_pr.footer_references << Wordprocessingml::FooterReference.new(type: type, r_id: r_id)
        end
      end

      def serialize_headers(content)
        return unless document&.headers && !document.headers.empty?

        idx = 0
        document.headers.each_value do |header_obj|
          idx += 1
          content["word/header#{idx}.xml"] =
            header_obj.to_xml(encoding: "UTF-8", prefix: true, fix_boolean_elements: true)
        end
      end

      def serialize_footers(content)
        return unless document&.footers && !document.footers.empty?

        idx = 0
        document.footers.each_value do |footer_obj|
          idx += 1
          content["word/footer#{idx}.xml"] =
            footer_obj.to_xml(encoding: "UTF-8", prefix: true, fix_boolean_elements: true)
        end
      end

      def serialize_header_footer_parts(content)
        return unless document&.header_footer_parts && !document.header_footer_parts.empty?

        document.header_footer_parts.each do |part|
          content["word/#{part[:target]}"] =
            part[:content].to_xml(encoding: "UTF-8", prefix: true, fix_boolean_elements: true)
        end
      end
    end
  end
end
