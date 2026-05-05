# frozen_string_literal: true

module Uniword
  module Transformation
    # Converts OOXML DocumentRoot to Mhtml::Document for full-fidelity MHT output.
    #
    # This is COMPLETELY SEPARATE from OoxmlToHtmlConverter which produces HTML5.
    # This converter produces Word HTML4 with proper MIME multipart structure.
    #
    # Delegates to:
    # - MhtmlStyleBuilder for static style templates
    # - MhtmlElementRenderer for element-to-HTML conversion
    # - MhtmlMetadataBuilder for metadata, properties, and file parts
    #
    # @example Transform DOCX to MHT
    #   docx_doc = Uniword::Docx::Package.from_file("document.docx")
    #   mhtml_doc = OoxmlToMhtmlConverter.document_to_mht(docx_doc)
    #   output = Uniword::Infrastructure::MimePackager.new(mhtml_doc).build_mime_content
    #
    class OoxmlToMhtmlConverter
      # Static MsoNormalTable CSS (used in wrap_html_document head)
      MSO_NORMAL_TABLE_STYLE = <<~CSS
        <!--[if gte mso 10]>
        <style>
         /* Style Definitions */
         table.MsoNormalTable
        	{mso-style-name:"Table Normal";
        	mso-tstyle-rowband-size:0;
        	mso-tstyle-colband-size:0;
        	mso-style-noshow:yes;
        	mso-style-priority:99;
        	mso-style-parent:"";
        	mso-padding-alt:0in 5.4pt 0in 5.4pt;
        	mso-para-margin-top:0in;
        	mso-para-margin-right:0in;
        	mso-para-margin-bottom:8.0pt;
        	mso-para-margin-left:0in;
        	line-height:115%;
        	mso-pagination:widow-orphan;
        	font-size:12.0pt;
        	font-family:"Aptos",sans-serif;
        	mso-ascii-font-family:Aptos;
        	mso-ascii-theme-font:minor-latin;
        	mso-hansi-font-family:Aptos;
        	mso-hansi-theme-font:minor-latin;
        	mso-font-kerning:1.0pt;
        	mso-ligatures:standardcontextual;}
        </style>
        <![endif]-->
      CSS

      # Static VML behavior style block
      VML_BEHAVIOR_STYLE = <<~CSS
        <!--[if !mso]>
        <style>
        v:* {behavior:url(#default#VML);}
        o:* {behavior:url(#default#VML);}
        w:* {behavior:url(#default#VML);}
        .shape {behavior:url(#default#VML);}
        </style>
        <![endif]-->
      CSS

      # Static WordDocument XML block (compatibility settings + MathPr)
      WORD_DOCUMENT_XML = <<~XML
        <!--[if gte mso 9]><xml>
         <w:WordDocument xmlns:w="urn:schemas-microsoft-com:office:word">
          <w:TrackMoves>false</w:TrackMoves>
          <w:TrackFormatting/>
          <w:PunctuationKerning/>
          <w:ValidateAgainstSchemas/>
          <w:SaveIfXMLInvalid>false</w:SaveIfXMLInvalid>
          <w:IgnoreMixedContent>false</w:IgnoreMixedContent>
          <w:AlwaysShowPlaceholderText>false</w:AlwaysShowPlaceholderText>
          <w:DoNotPromoteQF/>
          <w:LidThemeOther>en-US</w:LidThemeOther>
          <w:LidThemeAsian>ZH-CN</w:LidThemeAsian>
          <w:LidThemeComplexScript>X-NONE</w:LidThemeComplexScript>
          <w:Compatibility>
           <w:BreakWrappedTables/>
           <w:SnapToGridInCell/>
           <w:WrapTextWithPunct/>
           <w:UseAsianBreakRules/>
           <w:DontGrowAutofit/>
           <w:SplitPgBreakAndParaMark/>
           <w:EnableOpenTypeKerning/>
           <w:DontFlipMirrorIndents/>
           <w:OverrideTableStyleHps/>
           <w:UseFELayout/>
          </w:Compatibility>
          <w:MathPr>
           <w:MathFont w:val="Cambria Math"/>
           <w:brkBin w:val="before"/>
           <w:brkBinSub w:val="&#45;-"/>
           <w:smallFrac w:val="off"/>
           <w:dispDef/>
           <w:lMargin w:val="0"/>
           <w:rMargin w:val="0"/>
           <w:defJc w:val="centerGroup"/>
           <w:wrapIndent w:val="1440"/>
           <w:intLim w:val="subSup"/>
           <w:naryLim w:val="undOvr"/>
          </w:MathPr>
         </w:WordDocument>
        </xml><![endif]-->
      XML

      # Static OfficeDocumentSettings XML
      OFFICE_SETTINGS_XML = <<~XML
        <o:OfficeDocumentSettings xmlns:o="urn:schemas-microsoft-com:office:office">
         <o:AllowPNG/>
        </o:OfficeDocumentSettings>
      XML

      # Convert OOXML DocumentRoot to Mhtml::Document
      #
      # @param document [Uniword::Wordprocessingml::DocumentRoot] OOXML document
      # @param core_properties [Uniword::Ooxml::CoreProperties] Optional core properties
      # @param relationships [Uniword::Ooxml::Relationships::PackageRelationships] Optional relationships
      # @param document_name [String] Optional document name
      # @return [Uniword::Mhtml::Document] MHT document model
      def self.document_to_mht(document, core_properties = nil, relationships = nil,
                               document_name = nil)
        converter = new(document, core_properties, relationships, document_name)
        converter.build_mhtml_document
      end

      # Convert OOXML DocumentRoot to HTML body content (for Mhtml::HtmlPart)
      #
      # @param document [Uniword::Wordprocessingml::DocumentRoot] OOXML document
      # @param core_properties [Uniword::Ooxml::CoreProperties] Optional core properties
      # @param relationships [Uniword::Ooxml::Relationships::PackageRelationships] Optional relationships
      # @return [String] Word HTML4 body content
      def self.document_to_html_body(document, core_properties = nil,
relationships = nil)
        converter = new(document, core_properties, relationships)
        converter.build_html_body
      end

      def initialize(document, core_properties = nil, relationships = nil,
document_name = nil)
        @document = document
        @relationships = relationships
        @core_properties = core_properties

        @metadata_builder = MhtmlMetadataBuilder.new(
          document, core_properties, relationships, document_name
        )
        @element_renderer = MhtmlElementRenderer.new(relationships,
                                                     document.image_parts)
      end

      # Get the core properties to use (provided or from document)
      def core_properties
        @core_properties || @document.core_properties
      end

      # Get document name via metadata builder
      def document_name
        @metadata_builder.document_name
      end

      # Build the complete Mhtml::Document
      def build_mhtml_document
        mhtml_doc = Uniword::Mhtml::Document.new

        # Build HTML content
        html_content = build_html_body
        html_part = Uniword::Mhtml::HtmlPart.new
        html_part.content_type = "text/html"
        html_part.content_transfer_encoding = "quoted-printable"
        html_part.raw_content = html_content
        html_part.content_location = "file:///C:/D057922B/#{document_name}.htm"

        mhtml_doc.html_part = html_part
        mhtml_doc.parts << html_part

        # Build metadata
        mhtml_doc.document_properties = @metadata_builder.build_document_properties

        # Build filelist.xml
        filelist_part = @metadata_builder.build_filelist_part
        mhtml_doc.parts << filelist_part if filelist_part

        # Build image parts from document.image_parts
        @metadata_builder.build_image_parts.each do |image_part|
          mhtml_doc.parts << image_part
        end

        # Generate deterministic boundary based on document name
        hash = document_name.gsub(/[^a-zA-Z0-9]/, "").upcase[0..7] || "DOC"
        mhtml_doc.boundary = "----=_NextPart_01DC60F8.#{hash}"

        mhtml_doc
      end

      # Build the HTML body content
      def build_html_body
        body = @document.body
        return "" unless body

        # Split body elements into sections based on paragraph section_properties
        sections = split_into_sections(body.elements)

        wrap_html_document(sections)
      end

      private

      # Wrap HTML content in full Word HTML document
      def wrap_html_document(sections)
        name = document_name
        meta_tags = @metadata_builder.build_meta_tags
        link_tags = @metadata_builder.build_link_tags
        metadata_comments = @metadata_builder.build_metadata_comments
        custom_props = @metadata_builder.build_custom_document_properties

        # Build body content from sections
        body_content = build_sections_html(sections)

        <<~HTML
          <html xmlns:o="urn:schemas-microsoft-com:office:office"
          xmlns:w="urn:schemas-microsoft-com:office:word"
          xmlns:m="http://schemas.microsoft.com/office/2004/12/omml"
          xmlns="http://www.w3.org/TR/REC-html40">
          <head>
          #{meta_tags}
          #{link_tags}
          <!--[if gte mso 9]><xml>
           <o:DocumentProperties xmlns:o="urn:schemas-microsoft-com:office:office">
          #{metadata_comments}
           </o:DocumentProperties>
          #{custom_props}
           #{OFFICE_SETTINGS_XML}
          </xml><![endif]-->
          <link rel=themeData href="#{name}.fld/themedata.thmx">
          <link rel=colorSchemeMapping href="#{name}.fld/colorschememapping.xml">
          #{WORD_DOCUMENT_XML}
          #{VML_BEHAVIOR_STYLE}
          #{MhtmlStyleBuilder.latent_styles}
          #{MhtmlStyleBuilder.style_block}
          #{MSO_NORMAL_TABLE_STYLE}
          </head>
          <body lang=EN-US style='tab-interval:.5in;word-wrap:break-word'>

          #{body_content}

          </body>
          </html>
        HTML
      end

      # Split body elements into sections based on paragraph section_properties.
      # Returns an array of arrays: each inner array is one section's elements.
      def split_into_sections(elements)
        return [elements] if elements.empty?

        sections = []
        current_section = []

        elements.each do |element|
          current_section << element

          # Check if this paragraph marks a section boundary
          if element.is_a?(Uniword::Wordprocessingml::Paragraph) &&
              element.properties&.section_properties
            sections << current_section
            current_section = []
          end
        end

        # Add remaining elements as the last section
        sections << current_section unless current_section.empty?

        sections
      end

      # Build HTML body content from sections array.
      # Each section is wrapped in a <div class=WordSectionN> with <br> between them.
      def build_sections_html(sections)
        return "" if sections.empty?

        # Single section: wrap in WordSection1 without breaks
        if sections.size == 1
          elements_html = sections.first.map do |element|
            @element_renderer.element_to_html(element)
          end.join("\n")
          return "<div class=WordSection1>\n\n#{elements_html}\n\n</div>"
        end

        section_divs = sections.each_with_index.map do |section_elements, idx|
          elements_html = section_elements.map do |element|
            @element_renderer.element_to_html(element)
          end.join("\n")

          # First N sections get WordSection1..N class, last section is unnamed
          if idx < sections.size - 1
            "<div class=WordSection#{idx + 1}>\n\n#{elements_html}\n\n</div>"
          else
            "<div class=>\n\n#{elements_html}\n\n</div>"
          end
        end

        # Join with <br> between sections (not after the last one)
        # Word HTML uses <br clear="all" class="section" /> between sections
        section_divs.join("\n\n<br clear=\"all\" class=\"section\" />\n\n")
      end
    end
  end
end
