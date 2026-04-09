# frozen_string_literal: true

module Uniword
  module Mhtml
    # Header/Footer HTML MIME part — separate HTML files for headers/footers.
    class HeaderFooterPart < MimePart
      def html_content
        decoded_content
      end
    end
  end
end
