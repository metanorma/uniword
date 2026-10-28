# frozen_string_literal: true

module Uniword
  module Mhtml
    # XML MIME part — filelist.xml, props*.xml, colorschememapping.xml, etc.
    class XmlPart < MimePart
      def xml_content
        @xml_content ||= Moxml.parse(decoded_content)
      rescue Moxml::ParseError
        @xml_content ||= Moxml.parse(decoded_content)
      end

      def to_xml
        decoded_content
      end
    end
  end
end
