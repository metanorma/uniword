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
      attribute :header_references, HeaderReference, collection: true, initialize_empty: true
      attribute :footer_references, FooterReference, collection: true, initialize_empty: true
      attribute :type, :string
      attribute :page_numbering, PageNumbering
      attribute :doc_grid, DocGrid
      attribute :footnote_pr, FootnotePr
      attribute :title_pg, TitlePg
      attribute :footnote_columns, Uniword::Wordprocessingml2013::FootnoteColumns

      # Revision tracking attributes
      attribute :rsid_r, :string
      attribute :rsid_r_default, :string
      attribute :rsid_p, :string
      attribute :rsid_r_pr, :string
      # W14 namespace typed attributes
      attribute :para_id, W14ParaId
      attribute :text_id, W14TextId

      xml do
        element 'sectPr'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        ordered

        # Revision tracking attributes
        map_attribute 'rsidR', to: :rsid_r, render_nil: false
        map_attribute 'rsidRDefault', to: :rsid_r_default, render_nil: false
        map_attribute 'rsidP', to: :rsid_p, render_nil: false
        map_attribute 'rsidRPr', to: :rsid_r_pr, render_nil: false
        # W14 namespace typed attributes - namespace declared on the type class
        map_attribute 'paraId', to: :para_id, render_nil: false
        map_attribute 'textId', to: :text_id, render_nil: false

        map_element 'pgSz', to: :page_size, render_nil: false
        map_element 'pgMar', to: :page_margins, render_nil: false
        map_element 'cols', to: :columns, render_nil: false
        map_element 'headerReference', to: :header_references, render_nil: false
        map_element 'footerReference', to: :footer_references, render_nil: false
        map_attribute 'val', to: :type
        map_element 'pgNumType', to: :page_numbering, render_nil: false
        map_element 'docGrid', to: :doc_grid, render_nil: false
        map_element 'footnotePr', to: :footnote_pr, render_nil: false
        map_element 'titlePg', to: :title_pg, render_nil: false
        map_element 'footnoteColumns', to: :footnote_columns, render_nil: false
      end
    end
  end
end
