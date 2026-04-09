# frozen_string_literal: true

module Uniword
  module Mhtml
    # XML MIME part — filelist.xml, props*.xml, colorschememapping.xml, etc.
    class XmlPart < MimePart
      def xml_content
        @xml_content ||= Nokogiri::XML(decoded_content) { |config| config.strict.noblanks }
      rescue Nokogiri::XML::SyntaxError
        @xml_content ||= Nokogiri::XML(decoded_content)
      end

      def to_xml
        decoded_content
      end
    end
  end
end
