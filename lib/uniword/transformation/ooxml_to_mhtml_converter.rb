# frozen_string_literal: true

require 'nokogiri'

module Uniword
  module Transformation
    # Converts OOXML DocumentRoot to Mhtml::Document for full-fidelity MHT output.
    #
    # This is COMPLETELY SEPARATE from OoxmlToHtmlConverter which produces HTML5.
    # This converter produces Word HTML4 with proper MIME multipart structure.
    #
    # @example Transform DOCX to MHT
    #   docx_doc = Uniword::Ooxml::DocxPackage.from_file("document.docx")
    #   mhtml_doc = OoxmlToMhtmlConverter.document_to_mht(docx_doc)
    #   output = Uniword::Infrastructure::MimePackager.new(mhtml_doc).build_mime_content
    #
    class OoxmlToMhtmlConverter
      # Convert OOXML DocumentRoot to Mhtml::Document
      #
      # @param document [Uniword::Wordprocessingml::DocumentRoot] OOXML document
      # @param core_properties [Uniword::Ooxml::CoreProperties] Optional core properties
      #   (if not provided, uses document.core_properties which may be lazily initialized)
      # @param relationships [Uniword::Ooxml::Relationships::PackageRelationships] Optional relationships
      # @param document_name [String] Optional document name (e.g., 'blank'). If not provided,
      #   extracts from relationships or defaults to 'document'
      # @return [Uniword::Mhtml::Document] MHT document model
      def self.document_to_mht(document, core_properties = nil, relationships = nil, document_name = nil)
        converter = new(document, core_properties, relationships, document_name)
        converter.build_mhtml_document
      end

      # Convert OOXML DocumentRoot to HTML body content (for Mhtml::HtmlPart)
      #
      # @param document [Uniword::Wordprocessingml::DocumentRoot] OOXML document
      # @param core_properties [Uniword::Ooxml::CoreProperties] Optional core properties
      # @param relationships [Uniword::Ooxml::Relationships::PackageRelationships] Optional relationships
      # @return [String] Word HTML4 body content
      def self.document_to_html_body(document, core_properties = nil, relationships = nil)
        converter = new(document, core_properties, relationships)
        converter.build_html_body
      end

      def initialize(document, core_properties = nil, relationships = nil, document_name = nil)
        @document = document
        @relationships = relationships
        @provided_document_name = document_name
        # Use provided core_properties if given, otherwise use document's (which may be lazily initialized)
        @core_properties = core_properties
      end

      # Get the core properties to use (provided or from document)
      def core_properties
        @core_properties || @document.core_properties
      end

      # Build the complete Mhtml::Document
      def build_mhtml_document
        mhtml_doc = Uniword::Mhtml::Document.new

        # Build HTML content
        html_content = build_html_body
        html_part = Uniword::Mhtml::HtmlPart.new
        html_part.content_type = 'text/html'
        html_part.content_transfer_encoding = 'quoted-printable'
        html_part.raw_content = html_content
        html_part.content_location = "file:///C:/D057922B/#{document_name}.htm"

        mhtml_doc.html_part = html_part
        mhtml_doc.parts << html_part

        # Build metadata
        mhtml_doc.document_properties = build_document_properties

        # Build filelist.xml
        filelist_part = build_filelist_part
        mhtml_doc.parts << filelist_part if filelist_part

        # Generate deterministic boundary based on document name
        # Word uses format: ----=_NextPart_XXXX.XXXX
        hash = document_name.gsub(/[^a-zA-Z0-9]/, '').upcase[0..7] || 'DOC'
        mhtml_doc.boundary = "----=_NextPart_01DC60F8.#{hash}"

        mhtml_doc
      end

      # Build the HTML body content
      def build_html_body
        body = @document.body
        return '' unless body

        paragraphs_html = body.elements.map do |element|
          element_to_html(element)
        end.join("\n")

        wrap_html_document(paragraphs_html)
      end

      private

      # Build document properties from core properties
      def build_document_properties
        props = Uniword::Mhtml::Metadata::DocumentProperties.new
        cp = core_properties

        if cp
          props.author = cp.creator.to_s if cp.respond_to?(:creator) && cp.creator
          # Use .value for date types, not .to_s (which returns object inspect)
          props.created = cp.created.value.to_s if cp.respond_to?(:created) && cp.created
          props.last_author = cp.last_modified_by.to_s if cp.respond_to?(:last_modified_by) && cp.last_modified_by
          props.last_saved = cp.modified.value.to_s if cp.respond_to?(:modified) && cp.modified
          props.pages = cp.pages.to_s if cp.respond_to?(:pages) && cp.pages
          props.words = cp.words.to_s if cp.respond_to?(:words) && cp.words
          props.characters = cp.characters.to_s if cp.respond_to?(:characters) && cp.characters
          props.application = 'Microsoft Word'
        end

        props
      end

      # Build filelist.xml part
      def build_filelist_part
        filelist_xml = <<~XML
          <xml xmlns:o="urn:schemas-microsoft-com:office:office">
            <o:MainFile HRef="../#{document_name}.htm"/>
            <o:File HRef="filelist.xml"/>
          </xml>
        XML

        part = Uniword::Mhtml::XmlPart.new
        part.content_type = 'text/xml; charset="utf-8"'
        part.content_transfer_encoding = 'quoted-printable'
        part.raw_content = filelist_xml
        part.content_location = "file:///C:/D057922B/#{document_name}.fld/filelist.xml"

        part
      end

      # Wrap HTML content in full Word HTML document
      def wrap_html_document(body_html)
        metadata_comments = build_metadata_comments
        meta_tags = build_meta_tags
        link_tags = build_link_tags
        style_block = build_style_block

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
           <o:OfficeDocumentSettings xmlns:o="urn:schemas-microsoft-com:office:office">
            <o:AllowPNG/>
           </o:OfficeDocumentSettings>
          </xml><![endif]-->
          <link rel=themeData href="#{document_name}.fld/themedata.thmx">
          <link rel=colorSchemeMapping href="#{document_name}.fld/colorschememapping.xml">
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
          #{build_latent_styles}
          #{style_block}
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
          </head>
          <body lang=EN-US style='tab-interval:.5in;word-wrap:break-word'>

          <div class=WordSection1>

          #{body_html}

          </div>

          </body>
          </html>
        HTML
      end

      # Build the o:DocumentProperties content lines
      def build_metadata_comments
        props = core_properties
        return '' unless props

        author = props.respond_to?(:creator) ? props.creator : nil
        last_author = props.respond_to?(:last_modified_by) ? props.last_modified_by : nil
        revision = props.respond_to?(:revision) ? props.revision : nil
        # created and modified are specialized types, use .value to get the actual date
        created = props.respond_to?(:created) && props.created ? props.created.value : nil
        last_saved = props.respond_to?(:modified) && props.modified ? props.modified.value : nil

        doc_props = []
        doc_props << " <o:Author>#{escape_xml(author)}</o:Author>" if author
        doc_props << " <o:LastAuthor>#{escape_xml(last_author)}</o:LastAuthor>" if last_author
        doc_props << " <o:Revision>#{escape_xml(revision)}</o:Revision>" if revision
        doc_props << " <o:TotalTime>0</o:TotalTime>"
        doc_props << " <o:Created>#{escape_xml(created)}</o:Created>" if created
        doc_props << " <o:LastSaved>#{escape_xml(last_saved)}</o:LastSaved>" if last_saved
        doc_props << " <o:Pages>1</o:Pages>"
        doc_props << " <o:Words>0</o:Words>"
        doc_props << " <o:Characters>0</o:Characters>"
        doc_props << " <o:Version>16.00</o:Version>"

        doc_props.join("\n")
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

      # Get document name - use provided name, or extract from relationships, or default
      def document_name
        @document_name ||= @provided_document_name || begin
          # Try package_rels (has the main document relationship)
          if @relationships
            rel = @relationships.relationships.find do |r|
              r.target.to_s.include?('document.xml')
            end
            if rel
              target = rel.target # e.g., "word/document.xml"
              # Extract "document" from "word/document.xml"
              parts = target.split('/')
              return parts.last.sub(/\.xml$/, '') if parts.last
            end
          end
          # Fallback to document_rels from document itself
          location = @document.document_rels&.relationships&.first&.target || 'document'
          File.basename(location, '.*')
        rescue
          'document'
        end
      end

      # Build the w:LatentStyles block with all 376 entries
      def build_latent_styles
        <<~LATENT
          <!--[if gte mso 9]><xml>
           <w:LatentStyles DefLockedState="false" DefUnhideWhenUsed="false"
           DefSemiHidden="false" DefQFormat="false" DefPriority="99"
           LatentStyleCount="376">
           <w:LsdException Locked="false" Priority="0" QFormat="true" Name="Normal"/>
           <w:LsdException Locked="false" Priority="9" QFormat="true" Name="heading 1"/>
           <w:LsdException Locked="false" Priority="9" SemiHidden="true" UnhideWhenUsed="true" QFormat="true" Name="heading 2"/>
           <w:LsdException Locked="false" Priority="9" SemiHidden="true" UnhideWhenUsed="true" QFormat="true" Name="heading 3"/>
           <w:LsdException Locked="false" Priority="9" SemiHidden="true" UnhideWhenUsed="true" QFormat="true" Name="heading 4"/>
           <w:LsdException Locked="false" Priority="9" SemiHidden="true" UnhideWhenUsed="true" QFormat="true" Name="heading 5"/>
           <w:LsdException Locked="false" Priority="9" SemiHidden="true" UnhideWhenUsed="true" QFormat="true" Name="heading 6"/>
           <w:LsdException Locked="false" Priority="9" SemiHidden="true" UnhideWhenUsed="true" QFormat="true" Name="heading 7"/>
           <w:LsdException Locked="false" Priority="9" SemiHidden="true" UnhideWhenUsed="true" QFormat="true" Name="heading 8"/>
           <w:LsdException Locked="false" Priority="9" SemiHidden="true" UnhideWhenUsed="true" QFormat="true" Name="heading 9"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="index 1"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="index 2"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="index 3"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="index 4"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="index 5"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="index 6"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="index 7"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="index 8"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="index 9"/>
           <w:LsdException Locked="false" Priority="39" SemiHidden="true" UnhideWhenUsed="true" Name="toc 1"/>
           <w:LsdException Locked="false" Priority="39" SemiHidden="true" UnhideWhenUsed="true" Name="toc 2"/>
           <w:LsdException Locked="false" Priority="39" SemiHidden="true" UnhideWhenUsed="true" Name="toc 3"/>
           <w:LsdException Locked="false" Priority="39" SemiHidden="true" UnhideWhenUsed="true" Name="toc 4"/>
           <w:LsdException Locked="false" Priority="39" SemiHidden="true" UnhideWhenUsed="true" Name="toc 5"/>
           <w:LsdException Locked="false" Priority="39" SemiHidden="true" UnhideWhenUsed="true" Name="toc 6"/>
           <w:LsdException Locked="false" Priority="39" SemiHidden="true" UnhideWhenUsed="true" Name="toc 7"/>
           <w:LsdException Locked="false" Priority="39" SemiHidden="true" UnhideWhenUsed="true" Name="toc 8"/>
           <w:LsdException Locked="false" Priority="39" SemiHidden="true" UnhideWhenUsed="true" Name="toc 9"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Normal Indent"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="footnote text"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="annotation text"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="header"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="footer"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="index heading"/>
           <w:LsdException Locked="false" Priority="35" SemiHidden="true" UnhideWhenUsed="true" QFormat="true" Name="caption"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="table of figures"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="envelope address"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="envelope return"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="footnote reference"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="annotation reference"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="line number"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="page number"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="endnote reference"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="endnote text"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="table of authorities"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="macro"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="toa heading"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="List"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="List Bullet"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="List Number"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="List 2"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="List 3"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="List 4"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="List 5"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="List Bullet 2"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="List Bullet 3"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="List Bullet 4"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="List Bullet 5"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="List Number 2"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="List Number 3"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="List Number 4"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="List Number 5"/>
           <w:LsdException Locked="false" Priority="10" QFormat="true" Name="Title"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Closing"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Signature"/>
           <w:LsdException Locked="false" Priority="1" SemiHidden="true" UnhideWhenUsed="true" Name="Default Paragraph Font"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Body Text"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Body Text Indent"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="List Continue"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="List Continue 2"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="List Continue 3"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="List Continue 4"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="List Continue 5"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Message Header"/>
           <w:LsdException Locked="false" Priority="11" QFormat="true" Name="Subtitle"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Salutation"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Date"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Body Text First Indent"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Body Text First Indent 2"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Note Heading"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Body Text 2"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Body Text 3"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Body Text Indent 2"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Body Text Indent 3"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Block Text"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Hyperlink"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="FollowedHyperlink"/>
           <w:LsdException Locked="false" Priority="22" QFormat="true" Name="Strong"/>
           <w:LsdException Locked="false" Priority="20" QFormat="true" Name="Emphasis"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Document Map"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Plain Text"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="E-mail Signature"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="HTML Top of Form"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="HTML Bottom of Form"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Normal (Web)"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="HTML Acronym"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="HTML Address"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="HTML Cite"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="HTML Code"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="HTML Definition"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="HTML Keyboard"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="HTML Preformatted"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="HTML Sample"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="HTML Typewriter"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="HTML Variable"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Normal Table"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="annotation subject"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="No List"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Outline List 1"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Outline List 2"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Outline List 3"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Table Simple 1"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Table Simple 2"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Table Simple 3"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Table Classic 1"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Table Classic 2"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Table Classic 3"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Table Classic 4"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Table Colorful 1"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Table Colorful 2"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Table Colorful 3"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Table Columns 1"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Table Columns 2"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Table Columns 3"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Table Columns 4"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Table Columns 5"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Table Grid 1"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Table Grid 2"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Table Grid 3"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Table Grid 4"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Table Grid 5"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Table Grid 6"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Table Grid 7"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Table Grid 8"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Table List 1"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Table List 2"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Table List 3"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Table List 4"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Table List 5"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Table List 6"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Table List 7"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Table List 8"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Table 3D effects 1"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Table 3D effects 2"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Table 3D effects 3"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Table Contemporary"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Table Elegant"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Table Professional"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Table Subtle 1"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Table Subtle 2"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Table Web 1"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Table Web 2"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Table Web 3"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Balloon Text"/>
           <w:LsdException Locked="false" Priority="39" Name="Table Grid"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Table Theme"/>
           <w:LsdException Locked="false" SemiHidden="true" Name="Placeholder Text"/>
           <w:LsdException Locked="false" Priority="1" QFormat="true" Name="No Spacing"/>
           <w:LsdException Locked="false" Priority="60" Name="Light Shading"/>
           <w:LsdException Locked="false" Priority="61" Name="Light List"/>
           <w:LsdException Locked="false" Priority="62" Name="Light Grid"/>
           <w:LsdException Locked="false" Priority="63" Name="Medium Shading 1"/>
           <w:LsdException Locked="false" Priority="64" Name="Medium Shading 2"/>
           <w:LsdException Locked="false" Priority="65" Name="Medium List 1"/>
           <w:LsdException Locked="false" Priority="66" Name="Medium List 2"/>
           <w:LsdException Locked="false" Priority="67" Name="Medium Grid 1"/>
           <w:LsdException Locked="false" Priority="68" Name="Medium Grid 2"/>
           <w:LsdException Locked="false" Priority="69" Name="Medium Grid 3"/>
           <w:LsdException Locked="false" Priority="70" Name="Dark List"/>
           <w:LsdException Locked="false" Priority="71" Name="Colorful Shading"/>
           <w:LsdException Locked="false" Priority="72" Name="Colorful List"/>
           <w:LsdException Locked="false" Priority="73" Name="Colorful Grid"/>
           <w:LsdException Locked="false" Priority="60" Name="Light Shading Accent 1"/>
           <w:LsdException Locked="false" Priority="61" Name="Light List Accent 1"/>
           <w:LsdException Locked="false" Priority="62" Name="Light Grid Accent 1"/>
           <w:LsdException Locked="false" Priority="63" Name="Medium Shading 1 Accent 1"/>
           <w:LsdException Locked="false" Priority="64" Name="Medium Shading 2 Accent 1"/>
           <w:LsdException Locked="false" Priority="65" Name="Medium List 1 Accent 1"/>
           <w:LsdException Locked="false" SemiHidden="true" Name="Revision"/>
           <w:LsdException Locked="false" Priority="34" QFormat="true" Name="List Paragraph"/>
           <w:LsdException Locked="false" Priority="29" QFormat="true" Name="Quote"/>
           <w:LsdException Locked="false" Priority="30" QFormat="true" Name="Intense Quote"/>
           <w:LsdException Locked="false" Priority="66" Name="Medium List 2 Accent 1"/>
           <w:LsdException Locked="false" Priority="67" Name="Medium Grid 1 Accent 1"/>
           <w:LsdException Locked="false" Priority="68" Name="Medium Grid 2 Accent 1"/>
           <w:LsdException Locked="false" Priority="69" Name="Medium Grid 3 Accent 1"/>
           <w:LsdException Locked="false" Priority="70" Name="Dark List Accent 1"/>
           <w:LsdException Locked="false" Priority="71" Name="Colorful Shading Accent 1"/>
           <w:LsdException Locked="false" Priority="72" Name="Colorful List Accent 1"/>
           <w:LsdException Locked="false" Priority="73" Name="Colorful Grid Accent 1"/>
           <w:LsdException Locked="false" Priority="60" Name="Light Shading Accent 2"/>
           <w:LsdException Locked="false" Priority="61" Name="Light List Accent 2"/>
           <w:LsdException Locked="false" Priority="62" Name="Light Grid Accent 2"/>
           <w:LsdException Locked="false" Priority="63" Name="Medium Shading 1 Accent 2"/>
           <w:LsdException Locked="false" Priority="64" Name="Medium Shading 2 Accent 2"/>
           <w:LsdException Locked="false" Priority="65" Name="Medium List 1 Accent 2"/>
           <w:LsdException Locked="false" Priority="66" Name="Medium List 2 Accent 2"/>
           <w:LsdException Locked="false" Priority="67" Name="Medium Grid 1 Accent 2"/>
           <w:LsdException Locked="false" Priority="68" Name="Medium Grid 2 Accent 2"/>
           <w:LsdException Locked="false" Priority="69" Name="Medium Grid 3 Accent 2"/>
           <w:LsdException Locked="false" Priority="70" Name="Dark List Accent 2"/>
           <w:LsdException Locked="false" Priority="71" Name="Colorful Shading Accent 2"/>
           <w:LsdException Locked="false" Priority="72" Name="Colorful List Accent 2"/>
           <w:LsdException Locked="false" Priority="73" Name="Colorful Grid Accent 2"/>
           <w:LsdException Locked="false" Priority="60" Name="Light Shading Accent 3"/>
           <w:LsdException Locked="false" Priority="61" Name="Light List Accent 3"/>
           <w:LsdException Locked="false" Priority="62" Name="Light Grid Accent 3"/>
           <w:LsdException Locked="false" Priority="63" Name="Medium Shading 1 Accent 3"/>
           <w:LsdException Locked="false" Priority="64" Name="Medium Shading 2 Accent 3"/>
           <w:LsdException Locked="false" Priority="65" Name="Medium List 1 Accent 3"/>
           <w:LsdException Locked="false" Priority="66" Name="Medium List 2 Accent 3"/>
           <w:LsdException Locked="false" Priority="67" Name="Medium Grid 1 Accent 3"/>
           <w:LsdException Locked="false" Priority="68" Name="Medium Grid 2 Accent 3"/>
           <w:LsdException Locked="false" Priority="69" Name="Medium Grid 3 Accent 3"/>
           <w:LsdException Locked="false" Priority="70" Name="Dark List Accent 3"/>
           <w:LsdException Locked="false" Priority="71" Name="Colorful Shading Accent 3"/>
           <w:LsdException Locked="false" Priority="72" Name="Colorful List Accent 3"/>
           <w:LsdException Locked="false" Priority="73" Name="Colorful Grid Accent 3"/>
           <w:LsdException Locked="false" Priority="60" Name="Light Shading Accent 4"/>
           <w:LsdException Locked="false" Priority="61" Name="Light List Accent 4"/>
           <w:LsdException Locked="false" Priority="62" Name="Light Grid Accent 4"/>
           <w:LsdException Locked="false" Priority="63" Name="Medium Shading 1 Accent 4"/>
           <w:LsdException Locked="false" Priority="64" Name="Medium Shading 2 Accent 4"/>
           <w:LsdException Locked="false" Priority="65" Name="Medium List 1 Accent 4"/>
           <w:LsdException Locked="false" Priority="66" Name="Medium List 2 Accent 4"/>
           <w:LsdException Locked="false" Priority="67" Name="Medium Grid 1 Accent 4"/>
           <w:LsdException Locked="false" Priority="68" Name="Medium Grid 2 Accent 4"/>
           <w:LsdException Locked="false" Priority="69" Name="Medium Grid 3 Accent 4"/>
           <w:LsdException Locked="false" Priority="70" Name="Dark List Accent 4"/>
           <w:LsdException Locked="false" Priority="71" Name="Colorful Shading Accent 4"/>
           <w:LsdException Locked="false" Priority="72" Name="Colorful List Accent 4"/>
           <w:LsdException Locked="false" Priority="73" Name="Colorful Grid Accent 4"/>
           <w:LsdException Locked="false" Priority="60" Name="Light Shading Accent 5"/>
           <w:LsdException Locked="false" Priority="61" Name="Light List Accent 5"/>
           <w:LsdException Locked="false" Priority="62" Name="Light Grid Accent 5"/>
           <w:LsdException Locked="false" Priority="63" Name="Medium Shading 1 Accent 5"/>
           <w:LsdException Locked="false" Priority="64" Name="Medium Shading 2 Accent 5"/>
           <w:LsdException Locked="false" Priority="65" Name="Medium List 1 Accent 5"/>
           <w:LsdException Locked="false" Priority="66" Name="Medium List 2 Accent 5"/>
           <w:LsdException Locked="false" Priority="67" Name="Medium Grid 1 Accent 5"/>
           <w:LsdException Locked="false" Priority="68" Name="Medium Grid 2 Accent 5"/>
           <w:LsdException Locked="false" Priority="69" Name="Medium Grid 3 Accent 5"/>
           <w:LsdException Locked="false" Priority="70" Name="Dark List Accent 5"/>
           <w:LsdException Locked="false" Priority="71" Name="Colorful Shading Accent 5"/>
           <w:LsdException Locked="false" Priority="72" Name="Colorful List Accent 5"/>
           <w:LsdException Locked="false" Priority="73" Name="Colorful Grid Accent 5"/>
           <w:LsdException Locked="false" Priority="60" Name="Light Shading Accent 6"/>
           <w:LsdException Locked="false" Priority="61" Name="Light List Accent 6"/>
           <w:LsdException Locked="false" Priority="62" Name="Light Grid Accent 6"/>
           <w:LsdException Locked="false" Priority="63" Name="Medium Shading 1 Accent 6"/>
           <w:LsdException Locked="false" Priority="64" Name="Medium Shading 2 Accent 6"/>
           <w:LsdException Locked="false" Priority="65" Name="Medium List 1 Accent 6"/>
           <w:LsdException Locked="false" Priority="66" Name="Medium List 2 Accent 6"/>
           <w:LsdException Locked="false" Priority="67" Name="Medium Grid 1 Accent 6"/>
           <w:LsdException Locked="false" Priority="68" Name="Medium Grid 2 Accent 6"/>
           <w:LsdException Locked="false" Priority="69" Name="Medium Grid 3 Accent 6"/>
           <w:LsdException Locked="false" Priority="70" Name="Dark List Accent 6"/>
           <w:LsdException Locked="false" Priority="71" Name="Colorful Shading Accent 6"/>
           <w:LsdException Locked="false" Priority="72" Name="Colorful List Accent 6"/>
           <w:LsdException Locked="false" Priority="73" Name="Colorful Grid Accent 6"/>
           <w:LsdException Locked="false" Priority="19" QFormat="true" Name="Subtle Emphasis"/>
           <w:LsdException Locked="false" Priority="21" QFormat="true" Name="Intense Emphasis"/>
           <w:LsdException Locked="false" Priority="31" QFormat="true" Name="Subtle Reference"/>
           <w:LsdException Locked="false" Priority="32" QFormat="true" Name="Intense Reference"/>
           <w:LsdException Locked="false" Priority="33" QFormat="true" Name="Book Title"/>
           <w:LsdException Locked="false" Priority="37" SemiHidden="true" UnhideWhenUsed="true" Name="Bibliography"/>
           <w:LsdException Locked="false" Priority="39" SemiHidden="true" UnhideWhenUsed="true" QFormat="true" Name="TOC Heading"/>
           <w:LsdException Locked="false" Priority="41" Name="Plain Table 1"/>
           <w:LsdException Locked="false" Priority="42" Name="Plain Table 2"/>
           <w:LsdException Locked="false" Priority="43" Name="Plain Table 3"/>
           <w:LsdException Locked="false" Priority="44" Name="Plain Table 4"/>
           <w:LsdException Locked="false" Priority="45" Name="Plain Table 5"/>
           <w:LsdException Locked="false" Priority="40" Name="Grid Table Light"/>
           <w:LsdException Locked="false" Priority="46" Name="Grid Table 1 Light"/>
           <w:LsdException Locked="false" Priority="47" Name="Grid Table 2"/>
           <w:LsdException Locked="false" Priority="48" Name="Grid Table 3"/>
           <w:LsdException Locked="false" Priority="49" Name="Grid Table 4"/>
           <w:LsdException Locked="false" Priority="50" Name="Grid Table 5 Dark"/>
           <w:LsdException Locked="false" Priority="51" Name="Grid Table 6 Colorful"/>
           <w:LsdException Locked="false" Priority="52" Name="Grid Table 7 Colorful"/>
           <w:LsdException Locked="false" Priority="46" Name="Grid Table 1 Light Accent 1"/>
           <w:LsdException Locked="false" Priority="47" Name="Grid Table 2 Accent 1"/>
           <w:LsdException Locked="false" Priority="48" Name="Grid Table 3 Accent 1"/>
           <w:LsdException Locked="false" Priority="49" Name="Grid Table 4 Accent 1"/>
           <w:LsdException Locked="false" Priority="50" Name="Grid Table 5 Dark Accent 1"/>
           <w:LsdException Locked="false" Priority="51" Name="Grid Table 6 Colorful Accent 1"/>
           <w:LsdException Locked="false" Priority="52" Name="Grid Table 7 Colorful Accent 1"/>
           <w:LsdException Locked="false" Priority="46" Name="Grid Table 1 Light Accent 2"/>
           <w:LsdException Locked="false" Priority="47" Name="Grid Table 2 Accent 2"/>
           <w:LsdException Locked="false" Priority="48" Name="Grid Table 3 Accent 2"/>
           <w:LsdException Locked="false" Priority="49" Name="Grid Table 4 Accent 2"/>
           <w:LsdException Locked="false" Priority="50" Name="Grid Table 5 Dark Accent 2"/>
           <w:LsdException Locked="false" Priority="51" Name="Grid Table 6 Colorful Accent 2"/>
           <w:LsdException Locked="false" Priority="52" Name="Grid Table 7 Colorful Accent 2"/>
           <w:LsdException Locked="false" Priority="46" Name="Grid Table 1 Light Accent 3"/>
           <w:LsdException Locked="false" Priority="47" Name="Grid Table 2 Accent 3"/>
           <w:LsdException Locked="false" Priority="48" Name="Grid Table 3 Accent 3"/>
           <w:LsdException Locked="false" Priority="49" Name="Grid Table 4 Accent 3"/>
           <w:LsdException Locked="false" Priority="50" Name="Grid Table 5 Dark Accent 3"/>
           <w:LsdException Locked="false" Priority="51" Name="Grid Table 6 Colorful Accent 3"/>
           <w:LsdException Locked="false" Priority="52" Name="Grid Table 7 Colorful Accent 3"/>
           <w:LsdException Locked="false" Priority="46" Name="Grid Table 1 Light Accent 4"/>
           <w:LsdException Locked="false" Priority="47" Name="Grid Table 2 Accent 4"/>
           <w:LsdException Locked="false" Priority="48" Name="Grid Table 3 Accent 4"/>
           <w:LsdException Locked="false" Priority="49" Name="Grid Table 4 Accent 4"/>
           <w:LsdException Locked="false" Priority="50" Name="Grid Table 5 Dark Accent 4"/>
           <w:LsdException Locked="false" Priority="51" Name="Grid Table 6 Colorful Accent 4"/>
           <w:LsdException Locked="false" Priority="52" Name="Grid Table 7 Colorful Accent 4"/>
           <w:LsdException Locked="false" Priority="46" Name="Grid Table 1 Light Accent 5"/>
           <w:LsdException Locked="false" Priority="47" Name="Grid Table 2 Accent 5"/>
           <w:LsdException Locked="false" Priority="48" Name="Grid Table 3 Accent 5"/>
           <w:LsdException Locked="false" Priority="49" Name="Grid Table 4 Accent 5"/>
           <w:LsdException Locked="false" Priority="50" Name="Grid Table 5 Dark Accent 5"/>
           <w:LsdException Locked="false" Priority="51" Name="Grid Table 6 Colorful Accent 5"/>
           <w:LsdException Locked="false" Priority="52" Name="Grid Table 7 Colorful Accent 5"/>
           <w:LsdException Locked="false" Priority="46" Name="Grid Table 1 Light Accent 6"/>
           <w:LsdException Locked="false" Priority="47" Name="Grid Table 2 Accent 6"/>
           <w:LsdException Locked="false" Priority="48" Name="Grid Table 3 Accent 6"/>
           <w:LsdException Locked="false" Priority="49" Name="Grid Table 4 Accent 6"/>
           <w:LsdException Locked="false" Priority="50" Name="Grid Table 5 Dark Accent 6"/>
           <w:LsdException Locked="false" Priority="51" Name="Grid Table 6 Colorful Accent 6"/>
           <w:LsdException Locked="false" Priority="52" Name="Grid Table 7 Colorful Accent 6"/>
           <w:LsdException Locked="false" Priority="46" Name="List Table 1 Light"/>
           <w:LsdException Locked="false" Priority="47" Name="List Table 2"/>
           <w:LsdException Locked="false" Priority="48" Name="List Table 3"/>
           <w:LsdException Locked="false" Priority="49" Name="List Table 4"/>
           <w:LsdException Locked="false" Priority="50" Name="List Table 5 Dark"/>
           <w:LsdException Locked="false" Priority="51" Name="List Table 6 Colorful"/>
           <w:LsdException Locked="false" Priority="52" Name="List Table 7 Colorful"/>
           <w:LsdException Locked="false" Priority="46" Name="List Table 1 Light Accent 1"/>
           <w:LsdException Locked="false" Priority="47" Name="List Table 2 Accent 1"/>
           <w:LsdException Locked="false" Priority="48" Name="List Table 3 Accent 1"/>
           <w:LsdException Locked="false" Priority="49" Name="List Table 4 Accent 1"/>
           <w:LsdException Locked="false" Priority="50" Name="List Table 5 Dark Accent 1"/>
           <w:LsdException Locked="false" Priority="51" Name="List Table 6 Colorful Accent 1"/>
           <w:LsdException Locked="false" Priority="52" Name="List Table 7 Colorful Accent 1"/>
           <w:LsdException Locked="false" Priority="46" Name="List Table 1 Light Accent 2"/>
           <w:LsdException Locked="false" Priority="47" Name="List Table 2 Accent 2"/>
           <w:LsdException Locked="false" Priority="48" Name="List Table 3 Accent 2"/>
           <w:LsdException Locked="false" Priority="49" Name="List Table 4 Accent 2"/>
           <w:LsdException Locked="false" Priority="50" Name="List Table 5 Dark Accent 2"/>
           <w:LsdException Locked="false" Priority="51" Name="List Table 6 Colorful Accent 2"/>
           <w:LsdException Locked="false" Priority="52" Name="List Table 7 Colorful Accent 2"/>
           <w:LsdException Locked="false" Priority="46" Name="List Table 1 Light Accent 3"/>
           <w:LsdException Locked="false" Priority="47" Name="List Table 2 Accent 3"/>
           <w:LsdException Locked="false" Priority="48" Name="List Table 3 Accent 3"/>
           <w:LsdException Locked="false" Priority="49" Name="List Table 4 Accent 3"/>
           <w:LsdException Locked="false" Priority="50" Name="List Table 5 Dark Accent 3"/>
           <w:LsdException Locked="false" Priority="51" Name="List Table 6 Colorful Accent 3"/>
           <w:LsdException Locked="false" Priority="52" Name="List Table 7 Colorful Accent 3"/>
           <w:LsdException Locked="false" Priority="46" Name="List Table 1 Light Accent 4"/>
           <w:LsdException Locked="false" Priority="47" Name="List Table 2 Accent 4"/>
           <w:LsdException Locked="false" Priority="48" Name="List Table 3 Accent 4"/>
           <w:LsdException Locked="false" Priority="49" Name="List Table 4 Accent 4"/>
           <w:LsdException Locked="false" Priority="50" Name="List Table 5 Dark Accent 4"/>
           <w:LsdException Locked="false" Priority="51" Name="List Table 6 Colorful Accent 4"/>
           <w:LsdException Locked="false" Priority="52" Name="List Table 7 Colorful Accent 4"/>
           <w:LsdException Locked="false" Priority="46" Name="List Table 1 Light Accent 5"/>
           <w:LsdException Locked="false" Priority="47" Name="List Table 2 Accent 5"/>
           <w:LsdException Locked="false" Priority="48" Name="List Table 3 Accent 5"/>
           <w:LsdException Locked="false" Priority="49" Name="List Table 4 Accent 5"/>
           <w:LsdException Locked="false" Priority="50" Name="List Table 5 Dark Accent 5"/>
           <w:LsdException Locked="false" Priority="51" Name="List Table 6 Colorful Accent 5"/>
           <w:LsdException Locked="false" Priority="52" Name="List Table 7 Colorful Accent 5"/>
           <w:LsdException Locked="false" Priority="46" Name="List Table 1 Light Accent 6"/>
           <w:LsdException Locked="false" Priority="47" Name="List Table 2 Accent 6"/>
           <w:LsdException Locked="false" Priority="48" Name="List Table 3 Accent 6"/>
           <w:LsdException Locked="false" Priority="49" Name="List Table 4 Accent 6"/>
           <w:LsdException Locked="false" Priority="50" Name="List Table 5 Dark Accent 6"/>
           <w:LsdException Locked="false" Priority="51" Name="List Table 6 Colorful Accent 6"/>
           <w:LsdException Locked="false" Priority="52" Name="List Table 7 Colorful Accent 6"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Mention"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Smart Hyperlink"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Hashtag"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Unresolved Mention"/>
           <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true" Name="Smart Link"/>
           </w:LatentStyles>
          </xml><![endif]-->
        LATENT
      end

      # Build the CSS style block
      def build_style_block
        <<~STYLE
          <style>
          <!--
           /* Font Definitions */
           @font-face
          	{font-family:"Cambria Math";
          	panose-1:2 4 5 3 5 4 6 3 2 4;
          	mso-font-charset:0;
          	mso-generic-font-family:roman;
          	mso-font-pitch:variable;
          	mso-font-signature:-536870145 1107305727 0 0 415 0;}
          @font-face
          	{font-family:DengXian;
          	panose-1:2 1 6 0 3 1 1 1 1 1;
          	mso-font-alt:等线;
          	mso-font-charset:134;
          	mso-generic-font-family:modern;
          	mso-font-pitch:fixed;
          	mso-font-signature:1 135135232 16 0 262144 0;}
          @font-face
          	{font-family:Aptos;
          	panose-1:2 11 0 4 2 2 2 2 2 4;
          	mso-font-charset:0;
          	mso-generic-font-family:swiss;
          	mso-font-pitch:variable;
          	mso-font-signature:536871559 3 0 0 415 0;}
          @font-face
          	{font-family:"\\@DengXian";
          	panose-1:2 1 6 0 3 1 1 1 1 1;
          	mso-font-charset:134;
          	mso-generic-font-family:auto;
          	mso-font-pitch:variable;
          	mso-font-signature:-1610612033 953122042 22 0 262159 0;}
           /* Style Definitions */
          p.MsoNormal, li.MsoNormal, div.MsoNormal
          	{mso-style-unhide:no;
          	mso-style-qformat:yes;
          	mso-style-parent:"";
          	margin-top:0in;
          	margin-right:0in;
          	margin-bottom:8.0pt;
          	margin-left:0in;
          	line-height:115%;
          	mso-pagination:widow-orphan;
          	font-size:12.0pt;
          	font-family:"Aptos",sans-serif;
          	mso-ascii-font-family:Aptos;
          	mso-ascii-theme-font:minor-latin;
          	mso-fareast-font-family:DengXian;
          	mso-fareast-theme-font:minor-fareast;
          	mso-hansi-font-family:Aptos;
          	mso-hansi-theme-font:minor-latin;
          	mso-bidi-font-family:"Times New Roman";
          	mso-bidi-theme-font:minor-bidi;
          	mso-font-kerning:1.0pt;
          	mso-ligatures:standardcontextual;}
          h1
          	{mso-style-priority:9;
          	mso-style-unhide:no;
          	mso-style-qformat:yes;
          	mso-style-link:"Heading 1 Char";
          	mso-style-next:Normal;
          	margin-top:.25in;
          	margin-right:0in;
          	margin-bottom:4.0pt;
          	margin-left:0in;
          	line-height:115%;
          	mso-pagination:widow-orphan lines-together;
          	page-break-after:avoid;
          	mso-outline-level:1;
          	font-size:20.0pt;
          	font-family:"Aptos Display",sans-serif;
          	mso-ascii-font-family:"Aptos Display";
          	mso-ascii-theme-font:major-latin;
          	mso-fareast-font-family:"DengXian Light";
          	mso-fareast-theme-font:major-fareast;
          	mso-hansi-font-family:"Aptos Display";
          	mso-hansi-theme-font:major-latin;
          	mso-bidi-font-family:"Times New Roman";
          	mso-bidi-theme-font:major-bidi;
          	color:#0F4761;
          	mso-themecolor:accent1;
          	mso-themeshade:191;
          	mso-font-kerning:1.0pt;
          	mso-ligatures:standardcontextual;
          	font-weight:normal;}
          h2
          	{mso-style-noshow:yes;
          	mso-style-priority:9;
          	mso-style-qformat:yes;
          	mso-style-link:"Heading 2 Char";
          	mso-style-next:Normal;
          	margin-top:8.0pt;
          	margin-right:0in;
          	margin-bottom:4.0pt;
          	margin-left:0in;
          	line-height:115%;
          	mso-pagination:widow-orphan lines-together;
          	page-break-after:avoid;
          	mso-outline-level:2;
          	font-size:16.0pt;
          	font-family:"Aptos Display",sans-serif;
          	mso-ascii-font-family:"Aptos Display";
          	mso-ascii-theme-font:major-latin;
          	mso-fareast-font-family:"DengXian Light";
          	mso-fareast-theme-font:major-fareast;
          	mso-hansi-font-family:"Aptos Display";
          	mso-hansi-theme-font:major-latin;
          	mso-bidi-font-family:"Times New Roman";
          	mso-bidi-theme-font:major-bidi;
          	color:#0F4761;
          	mso-themecolor:accent1;
          	mso-themeshade:191;
          	mso-font-kerning:1.0pt;
          	mso-ligatures:standardcontextual;
          	font-weight:normal;}
          h3
          	{mso-style-noshow:yes;
          	mso-style-priority:9;
          	mso-style-qformat:yes;
          	mso-style-link:"Heading 3 Char";
          	mso-style-next:Normal;
          	margin-top:8.0pt;
          	margin-right:0in;
          	margin-bottom:4.0pt;
          	margin-left:0in;
          	line-height:115%;
          	mso-pagination:widow-orphan lines-together;
          	page-break-after:avoid;
          	mso-outline-level:3;
          	font-size:14.0pt;
          	font-family:"Aptos",sans-serif;
          	mso-ascii-font-family:Aptos;
          	mso-ascii-theme-font:minor-latin;
          	mso-fareast-font-family:"DengXian Light";
          	mso-fareast-theme-font:major-fareast;
          	mso-hansi-font-family:Aptos;
          	mso-hansi-theme-font:minor-latin;
          	mso-bidi-font-family:"Times New Roman";
          	mso-bidi-theme-font:major-bidi;
          	color:#0F4761;
          	mso-themecolor:accent1;
          	mso-themeshade:191;
          	mso-font-kerning:1.0pt;
          	mso-ligatures:standardcontextual;
          	font-weight:normal;}
          h4
          	{mso-style-noshow:yes;
          	mso-style-priority:9;
          	mso-style-qformat:yes;
          	mso-style-link:"Heading 4 Char";
          	mso-style-next:Normal;
          	margin-top:4.0pt;
          	margin-right:0in;
          	margin-bottom:2.0pt;
          	margin-left:0in;
          	line-height:115%;
          	mso-pagination:widow-orphan lines-together;
          	page-break-after:avoid;
          	mso-outline-level:4;
          	font-size:12.0pt;
          	font-family:"Aptos",sans-serif;
          	mso-ascii-font-family:Aptos;
          	mso-ascii-theme-font:minor-latin;
          	mso-fareast-font-family:"DengXian Light";
          	mso-fareast-theme-font:major-fareast;
          	mso-hansi-font-family:Aptos;
          	mso-hansi-theme-font:minor-latin;
          	mso-bidi-font-family:"Times New Roman";
          	mso-bidi-theme-font:major-bidi;
          	color:#0F4761;
          	mso-themecolor:accent1;
          	mso-themeshade:191;
          	mso-font-kerning:1.0pt;
          	mso-ligatures:standardcontextual;
          	font-weight:normal;
          	font-style:italic;}
          h5
          	{mso-style-noshow:yes;
          	mso-style-priority:9;
          	mso-style-qformat:yes;
          	mso-style-link:"Heading 5 Char";
          	mso-style-next:Normal;
          	margin-top:4.0pt;
          	margin-right:0in;
          	margin-bottom:2.0pt;
          	margin-left:0in;
          	line-height:115%;
          	mso-pagination:widow-orphan lines-together;
          	page-break-after:avoid;
          	mso-outline-level:5;
          	font-size:12.0pt;
          	font-family:"Aptos",sans-serif;
          	mso-ascii-font-family:Aptos;
          	mso-ascii-theme-font:minor-latin;
          	mso-fareast-font-family:"DengXian Light";
          	mso-fareast-theme-font:major-fareast;
          	mso-hansi-font-family:Aptos;
          	mso-hansi-theme-font:minor-latin;
          	mso-bidi-font-family:"Times New Roman";
          	mso-bidi-theme-font:major-bidi;
          	color:#0F4761;
          	mso-themecolor:accent1;
          	mso-themeshade:191;
          	mso-font-kerning:1.0pt;
          	mso-ligatures:standardcontextual;
          	font-weight:normal;}
          h6
          	{mso-style-noshow:yes;
          	mso-style-priority:9;
          	mso-style-qformat:yes;
          	mso-style-link:"Heading 6 Char";
          	mso-style-next:Normal;
          	margin-top:2.0pt;
          	margin-right:0in;
          	margin-bottom:0in;
          	margin-left:0in;
          	line-height:115%;
          	mso-pagination:widow-orphan lines-together;
          	page-break-after:avoid;
          	mso-outline-level:6;
          	font-size:12.0pt;
          	font-family:"Aptos",sans-serif;
          	mso-ascii-font-family:Aptos;
          	mso-ascii-theme-font:minor-latin;
          	mso-fareast-font-family:"DengXian Light";
          	mso-fareast-theme-font:major-fareast;
          	mso-hansi-font-family:Aptos;
          	mso-hansi-theme-font:minor-latin;
          	mso-bidi-font-family:"Times New Roman";
          	mso-bidi-theme-font:major-bidi;
          	color:#595959;
          	mso-themecolor:text1;
          	mso-themetint:166;
          	mso-font-kerning:1.0pt;
          	mso-ligatures:standardcontextual;
          	font-weight:normal;
          	font-style:italic;}
          p.MsoTitle, li.MsoTitle, div.MsoTitle
          	{mso-style-priority:10;
          	mso-style-unhide:no;
          	mso-style-qformat:yes;
          	mso-style-link:"Title Char";
          	mso-style-next:Normal;
          	margin-top:0in;
          	margin-right:0in;
          	margin-bottom:4.0pt;
          	margin-left:0in;
          	mso-add-space:auto;
          	mso-pagination:widow-orphan;
          	font-size:28.0pt;
          	font-family:"Aptos Display",sans-serif;
          	mso-ascii-font-family:"Aptos Display";
          	mso-ascii-theme-font:major-latin;
          	mso-fareast-font-family:"DengXian Light";
          	mso-fareast-theme-font:major-fareast;
          	mso-hansi-font-family:"Aptos Display";
          	mso-hansi-theme-font:major-latin;
          	mso-bidi-font-family:"Times New Roman";
          	mso-bidi-theme-font:major-bidi;
          	letter-spacing:-.5pt;
          	mso-font-kerning:14.0pt;
          	mso-ligatures:standardcontextual;}
          p.MsoSubtitle, li.MsoSubtitle, div.MsoSubtitle
          	{mso-style-priority:11;
          	mso-style-unhide:no;
          	mso-style-qformat:yes;
          	mso-style-link:"Subtitle Char";
          	mso-style-next:Normal;
          	margin-top:0in;
          	margin-right:0in;
          	margin-bottom:8.0pt;
          	margin-left:0in;
          	line-height:115%;
          	mso-pagination:widow-orphan;
          	font-size:14.0pt;
          	font-family:"Aptos",sans-serif;
          	mso-ascii-font-family:Aptos;
          	mso-ascii-theme-font:minor-latin;
          	mso-fareast-font-family:"DengXian Light";
          	mso-fareast-theme-font:major-fareast;
          	mso-hansi-font-family:"Aptos Display";
          	mso-hansi-theme-font:major-latin;
          	mso-bidi-font-family:"Times New Roman";
          	mso-bidi-theme-font:major-bidi;
          	color:#595959;
          	mso-themecolor:text1;
          	mso-themetint:166;
          	letter-spacing:.75pt;
          	mso-font-kerning:1.0pt;
          	mso-ligatures:standardcontextual;}
          @page WordSection1
          	{size:8.5in 11.0in;
          	margin:1.0in 1.0in 1.0in 1.0in;
          	mso-header-margin:.5in;
          	mso-footer-margin:.5in;
          	mso-paper-source:0;}
          div.WordSection1
          	{page:WordSection1;}
          -->
          </style>
        STYLE
      end

      # Convert an OOXML element to HTML
      def element_to_html(element)
        case element
        when Uniword::Wordprocessingml::Paragraph
          paragraph_to_html(element)
        when Uniword::Wordprocessingml::Table
          table_to_html(element)
        else
          ''
        end
      end

      # Convert OOXML Paragraph to HTML
      def paragraph_to_html(paragraph)
        style_class = style_to_css_class(paragraph.style)

        # Build paragraph content including SDTs inline
        content = paragraph_content_to_html(paragraph)

        if content.strip.empty?
          %(<p#{style_class}><o:p>&nbsp;</o:p></p>)
        else
          %(<p#{style_class}>#{content}</p>)
        end
      end

      # Get paragraph content including runs, hyperlinks, SDTs
      def paragraph_content_to_html(paragraph)
        parts = []

        # Process runs and hyperlinks in order
        paragraph.runs.each do |run|
          parts << run_to_html(run)
        end

        paragraph.hyperlinks.each do |hyperlink|
          parts << hyperlink_to_html(hyperlink)
        end

        # Process SDTs - in DOCX SDTs can be block elements, but in MHT they're inline
        paragraph.sdts.each do |sdt|
          parts << sdt_to_inline_html(sdt)
        end

        parts.join
      end

      # Convert OOXML Run to HTML
      def run_to_html(run)
        text = run.text&.to_s || ''
        return '' if text.empty?

        # Escape raw text first, then apply formatting around it
        escaped = escape_html(text)

        props = run.properties
        if props
          escaped = apply_run_formatting(escaped, props)
        end

        escaped
      end

      # Apply run formatting (text must already be HTML-escaped)
      def apply_run_formatting(text, props)
        result = text

        # Bold/Italic: element presence means true (value may be nil)
        result = "<strong>#{result}</strong>" if props.bold && props.bold.value != false
        result = "<em>#{result}</em>" if props.italic && props.italic.value != false
        result = "<u>#{result}</u>" if props.underline&.value

        if props.color&.value
          result = %(<span style="color:#{props.color.value}">#{result}</span>)
        end

        if props.size&.value
          size_pt = props.size.value.to_f / 2
          result = %(<span style="font-size:#{size_pt}pt">#{result}</span>)
        end

        if props.font&.respond_to?(:ascii) && props.font.ascii
          result = %(<span style="font-family:'#{props.font.ascii}'">#{result}</span>)
        elsif props.font.is_a?(String) && !props.font.empty?
          result = %(<span style="font-family:'#{props.font}'">#{result}</span>)
        end

        result
      end

      # Convert OOXML Hyperlink to HTML
      def hyperlink_to_html(hyperlink)
        url = resolve_hyperlink_url(hyperlink)
        return '' unless url

        # Get hyperlink text from runs
        text = hyperlink.runs.map { |r| r.text.to_s }.join

        %(<a href="#{escape_html(url)}">#{escape_html(text)}</a>)
      end

      # Resolve hyperlink URL from relationship or anchor
      def resolve_hyperlink_url(hyperlink)
        # Internal anchor link
        if hyperlink.anchor
          return "##{hyperlink.anchor}"
        end

        # External link via relationship ID
        if hyperlink.id && @relationships
          rel = @relationships.relationships.find { |r| r.id == hyperlink.id }
          if rel && rel.target_mode == 'External'
            return rel.target
          end
        end

        nil
      end

      # Convert OOXML SDT block to inline MHT SDT
      def sdt_to_inline_html(sdt)
        return '' unless sdt.content

        sdt_props = sdt.properties
        sdt_content = sdt.content

        # Extract text content
        text = extract_sdt_text(sdt_content)

        # Build inline SDT
        sdt_attrs = build_sdt_attrs(sdt_props)

        if text.empty?
          %(<w:sdt#{sdt_attrs}><w:sdtPr></w:sdtPr></w:sdt>)
        else
          %(<w:sdt#{sdt_attrs}><w:sdtPr></w:sdtPr><w:sdtContent><span>#{escape_html(text)}</span></w:sdtContent></w:sdt>)
        end
      end

      # Extract text from SDT content
      def extract_sdt_text(content)
        return '' unless content

        # Content uses mixed_content - serialize back to XML and extract text
        xml = content.to_xml
        # Parse the XML to extract text content
        doc = Nokogiri::HTML(xml)
        doc.text.gsub(/\s+/, ' ').strip
      end

      # Build SDT attribute string
      def build_sdt_attrs(_props)
        attrs = []
        # TODO: Map SDT properties to attributes
        # ShowingPlcHdr, Temporary, DocPart, ID, etc.
        attrs.join(' ')
      end

      # Convert OOXML Table to HTML
      def table_to_html(table)
        rows = table.rows || []

        rows_html = rows.map do |row|
          cells = row.cells || []
          cells_html = cells.map { |cell| table_cell_to_html(cell) }.join

          %(<tr>#{cells_html}</tr>)
        end.join("\n")

        <<~HTML
          <table>
          #{rows_html}
          </table>
        HTML
      end

      # Convert OOXML TableCell to HTML
      def table_cell_to_html(cell)
        paragraphs = cell.paragraphs || []

        content = paragraphs.map do |para|
          paragraph_to_html(para)
        end.join("\n")

        <<~HTML
          <td>
          #{content}
          </td>
        HTML
      end

      # Map OOXML style to CSS class
      def style_to_css_class(style)
        return ' class=MsoNormal' unless style

        case style
        when 'Title' then ' class=MsoTitle'
        when 'Title2' then ' class=MsoTitle2'
        when 'Subtitle' then ' class=MsoSubtitle'
        when 'Heading1' then ' class=MsoHeading1'
        when 'Heading2' then ' class=MsoHeading2'
        when 'Heading3' then ' class=MsoHeading3'
        when 'Heading4' then ' class=MsoHeading4'
        when 'Heading5' then ' class=MsoHeading5'
        when 'Heading6' then ' class=MsoHeading6'
        when 'TOC1', 'TOC2', 'TOC3', 'TOC4', 'TOC5', 'TOC6', 'TOC7', 'TOC8', 'TOC9'
          ' class=MsoToc1'
        when 'SectionTitle' then ' class=SectionTitle'
        else
          ' class=MsoNormal'
        end
      end

      # Escape HTML special characters
      def escape_html(text)
        text.to_s
          .gsub('&', '&amp;')
          .gsub('<', '&lt;')
          .gsub('>', '&gt;')
          .gsub('"', '&quot;')
          .gsub("'", '&#39;')
      end

      # Escape XML special characters
      def escape_xml(text)
        text.to_s
          .gsub('&', '&amp;')
          .gsub('<', '&lt;')
          .gsub('>', '&gt;')
          .gsub('"', '&quot;')
          .gsub("'", '&apos;')
      end
    end
  end
end
