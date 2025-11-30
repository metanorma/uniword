# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Section properties for page layout
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:sectPr>
    class SectionProperties < Lutaml::Model::Serializable
      attribute :page_size, PageSize
      attribute :page_margins, PageMargins
      attribute :columns, Columns
      attribute :header_reference, HeaderReference
      attribute :footer_reference, FooterReference
      attribute :type, :string
      attribute :page_numbering, PageNumbering

      xml do
        element 'sectPr'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        map_element 'pgSz', to: :page_size, render_nil: false
        map_element 'pgMar', to: :page_margins, render_nil: false
        map_element 'cols', to: :columns, render_nil: false
        map_element 'headerReference', to: :header_reference, render_nil: false
        map_element 'footerReference', to: :footer_reference, render_nil: false
        map_attribute 'val', to: :type
        map_element 'pgNumType', to: :page_numbering, render_nil: false
      end
    end
  end
end
