# frozen_string_literal: true

module Uniword
  module Transformation
    # Builds metadata, document properties, and file parts for MHTML output.
    #
    # Extracted from OoxmlToMhtmlConverter for separation of responsibilities.
    #
    # @api private
    class MhtmlMetadataBuilder
      def initialize(document, core_properties, relationships, document_name)
        @document = document
        @core_properties = core_properties
        @relationships = relationships
        @provided_document_name = document_name
      end

      # Get the core properties to use (provided or from document)
      def core_properties
        @core_properties || @document.core_properties
      end

      # Get document name - use provided name, or extract from relationships,
      # or default
      def document_name
        @document_name ||= @provided_document_name || begin
          if @relationships
            rel = @relationships.relationships.find do |r|
              r.target.to_s.include?("document.xml")
            end
            if rel
              target = rel.target
              parts = target.split("/")
              return parts.last.sub(/\.xml$/, "") if parts.last
            end
          end
          location = @document.document_rels&.relationships&.first&.target || "document"
          File.basename(location, ".*")
        rescue StandardError => e
          Uniword.logger&.debug do
            "Falling back to 'document' name: #{e.message}"
          end
          "document"
        end
      end

      # Build document properties from core properties
      def build_document_properties
        props = Uniword::Mhtml::Metadata::DocumentProperties.new
        cp = core_properties

        if cp
          props.author = cp.creator.to_s if cp.respond_to?(:creator) && cp.creator
          props.created = cp.created.value.to_s if cp.respond_to?(:created) && cp.created
          props.last_author = cp.last_modified_by.to_s if cp.respond_to?(:last_modified_by) && cp.last_modified_by
          props.last_saved = cp.modified.value.to_s if cp.respond_to?(:modified) && cp.modified
          props.pages = cp.pages.to_s if cp.respond_to?(:pages) && cp.pages
          props.words = cp.words.to_s if cp.respond_to?(:words) && cp.words
          props.characters = cp.characters.to_s if cp.respond_to?(:characters) && cp.characters
          props.application = "Microsoft Word"
        end

        props
      end

      # Build filelist.xml part
      def build_filelist_part
        image_entries = if @document.image_parts && !@document.image_parts.empty?
                          @document.image_parts.map do |_r_id, image_data|
                            %(<o:File HRef="#{image_data[:target]}"/>)
                          end.join("\n            ")
                        else
                          ""
                        end

        filelist_xml = <<~XML
          <xml xmlns:o="urn:schemas-microsoft-com:office:office">
            <o:MainFile HRef="../#{document_name}.htm"/>
            <o:File HRef="filelist.xml"/>
            #{image_entries}
          </xml>
        XML

        part = Uniword::Mhtml::XmlPart.new
        part.content_type = 'text/xml; charset="utf-8"'
        part.content_transfer_encoding = "quoted-printable"
        part.raw_content = filelist_xml
        part.content_location = "file:///C:/D057922B/#{document_name}.fld/filelist.xml"

        part
      end

      # Build image parts from document.image_parts
      def build_image_parts
        return [] unless @document.image_parts && !@document.image_parts.empty?

        @document.image_parts.map do |_r_id, image_data|
          part = Uniword::Mhtml::ImagePart.new
          part.content_type = image_data[:content_type] || "image/png"
          part.content_transfer_encoding = "base64"
          part.raw_content = image_data[:data]
          part.content_location = "file:///C:/D057922B/#{document_name}.fld/#{image_data[:target]}"
          part
        end
      end

      # Build the o:DocumentProperties content lines
      def build_metadata_comments
        props = core_properties
        return "" unless props

        author = props.respond_to?(:creator) ? props.creator : nil
        last_author = props.respond_to?(:last_modified_by) ? props.last_modified_by : nil
        revision = props.respond_to?(:revision) ? props.revision : nil
        created = props.respond_to?(:created) && props.created ? props.created.value : nil
        last_saved = props.respond_to?(:modified) && props.modified ? props.modified.value : nil

        stats = calculate_document_stats

        doc_props = []
        doc_props << " <o:Author>#{escape_xml(author)}</o:Author>" if author
        doc_props << " <o:LastAuthor>#{escape_xml(last_author)}</o:LastAuthor>" if last_author
        doc_props << " <o:Revision>#{escape_xml(revision)}</o:Revision>" if revision
        doc_props << " <o:TotalTime>0</o:TotalTime>"
        doc_props << " <o:Created>#{escape_xml(created)}</o:Created>" if created
        doc_props << " <o:LastSaved>#{escape_xml(last_saved)}</o:LastSaved>" if last_saved
        doc_props << " <o:Pages>#{stats[:pages]}</o:Pages>"
        doc_props << " <o:Words>#{stats[:words]}</o:Words>"
        doc_props << " <o:Characters>#{stats[:characters]}</o:Characters>"
        doc_props << " <o:Lines>#{stats[:lines]}</o:Lines>"
        doc_props << " <o:Paragraphs>#{stats[:paragraphs]}</o:Paragraphs>"
        doc_props << " <o:CharactersWithSpaces>#{stats[:characters_with_spaces]}</o:CharactersWithSpaces>"
        doc_props << " <o:Version>16.00</o:Version>"

        doc_props.join("\n")
      end

      # Build o:CustomDocumentProperties for AssetID and other custom fields
      def build_custom_document_properties
        asset_id = custom_property("AssetID")
        return "" unless asset_id

        <<~XML
          <o:CustomDocumentProperties xmlns:o="urn:schemas-microsoft-com:office:office">
           <o:AssetID dt:dt="string">#{escape_xml(asset_id)}</o:AssetID>
          </o:CustomDocumentProperties>
        XML
      end

      # Build meta tags for the head
      def build_meta_tags
        <<~META
          <meta http-equiv=Content-Type content="text/html; charset=utf-8">
          <meta name=ProgId content=Word.Document>
          <meta name=Generator content="Microsoft Word 15">
          <meta name=Originator content="Microsoft Word 15">
        META
      end

      # Build link tags for the head
      def build_link_tags
        <<~LINK
          <link rel=File-List href="#{document_name}.fld/filelist.xml">
        LINK
      end

      private

      # Calculate document statistics from content
      def calculate_document_stats
        words = 0
        characters = 0
        paragraphs = 0
        lines = 0

        body = @document.body
        unless body
          return { words: 0, characters: 0, paragraphs: 0, lines: 0, pages: 1,
                   characters_with_spaces: 0 }
        end

        body.elements.each do |element|
          next unless element.is_a?(Uniword::Wordprocessingml::Paragraph)

          paragraphs += 1
          para_words = 0
          para_chars = 0

          element.runs.each do |run|
            text = run.text.to_s
            characters += text.length
            para_chars += text.length
            words += text.split.length
            para_words += text.split.length
          end

          para_lines = [1, (para_chars / 80.0).ceil].max
          lines += para_lines
        end

        pages = [1, (words / 500.0).ceil, (lines / 24.0).ceil].max

        {
          words: words,
          characters: characters,
          paragraphs: paragraphs,
          lines: lines,
          pages: pages,
          characters_with_spaces: characters + paragraphs,
        }
      end

      # Get a custom document property by name
      def custom_property(name)
        if @document.respond_to?(:core_properties) && @document.core_properties
          cp = @document.core_properties
          return cp.custom_properties[name] if cp.respond_to?(:custom_properties) && cp.custom_properties
        end
        nil
      end

      # Escape XML special characters
      def escape_xml(text)
        text.to_s
          .gsub("&", "&amp;")
          .gsub("<", "&lt;")
          .gsub(">", "&gt;")
          .gsub('"', "&quot;")
          .gsub("'", "&apos;")
      end
    end
  end
end
