# frozen_string_literal: true

module Uniword
  module Mhtml
    # HTML MIME part — the main document content in an MHTML file.
    #
    # Contains the Word HTML document with embedded XML metadata
    # (DocumentProperties, WordDocument settings, LatentStyles).
    class HtmlPart < MimePart
      # Parse the decoded HTML with Nokogiri
      def html_document
        @html_document ||= Nokogiri::HTML(decoded_content)
      end

      # Extract the <head> element as string
      def head_html
        node = html_document.at_css('head')
        node ? node.to_s : ''
      end

      # Extract the <body> element inner HTML
      def body_html
        node = html_document.at_css('body')
        node ? node.inner_html : ''
      end

      # Extract inline CSS styles from <style> tags
      def css_styles
        html_document.css('style').map(&:content).join("\n")
      end

      # Extract DocumentProperties XML from HTML head comments.
      #
      # Returns the <o:DocumentProperties> element as a string
      # with namespace declarations for lutaml-model parsing.
      def document_properties_xml
        extract_office_xml('DocumentProperties',
                          'urn:schemas-microsoft-com:office:office', 'o')
      end

      # Extract OfficeDocumentSettings XML from HTML head comments.
      def office_document_settings_xml
        extract_office_xml('OfficeDocumentSettings',
                          'urn:schemas-microsoft-com:office:office', 'o')
      end

      # Extract WordDocument XML from HTML head comments.
      def word_document_xml
        extract_office_xml('WordDocument',
                          'urn:schemas-microsoft-com:office:word', 'w')
      end

      # Extract LatentStyles XML from HTML head comments.
      def latent_styles_xml
        extract_office_xml('LatentStyles',
                          'urn:schemas-microsoft-com:office:word', 'w')
      end

      # Extract all <xml> blocks from head
      def xml_blocks
        html_document.at_css('head')&.xpath('comment()')&.map do |comment|
          text = comment.text
          if text =~ /<xml>(.*?)<\/xml>/m
            ::Regexp.last_match(1).strip
          end
        end&.compact || []
      end

      # Get the full HTML string
      def to_html
        html_document.to_s
      end

      # Get the body inner HTML
      def body_inner_html
        body_html
      end

      private

      # Extract a specific root element from MHTML head XML comments.
      #
      # MHTML embeds Office XML in <!--[if gte mso 9]> comments.
      # This method finds the requested root element and wraps it
      # with proper namespace declarations for lutaml-model.
      def extract_office_xml(element_name, namespace_uri, prefix)
        head = html_document.at_css('head')
        return nil unless head

        head.xpath('comment()').each do |comment|
          text = comment.text
          next unless text.include?("<#{prefix}:#{element_name}")

          # Extract the specific element with its content
          pattern = /(<#{prefix}:#{element_name}[^>]*>.*?<\/#{prefix}:#{element_name}>)/m
          if text =~ pattern
            xml = ::Regexp.last_match(1)
            # Ensure namespace declaration is present
            ns_decl = "xmlns:#{prefix}=\"#{namespace_uri}\""
            unless xml.include?(ns_decl)
              xml = xml.sub(/(<#{prefix}:#{element_name})/, "\\1 #{ns_decl}")
            end
            return xml
          end
        end
        nil
      end
    end
  end
end
