# frozen_string_literal: true

module Uniword
  module Mhtml
    # Theme data MIME part — .thmx file (Office theme package).
    #
    # The .thmx is itself a ZIP file containing theme parts
    # (theme/theme1.xml, theme/_rels/, [Content_Types].xml).
    class ThemePart < MimePart
      def theme_data
        decoded_content
      end

      def theme_data=(value)
        self.raw_content = value
      end
    end
  end
end
