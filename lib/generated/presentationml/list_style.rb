# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Presentationml
      # List styling properties
      #
      # Generated from OOXML schema: presentationml.yml
      # Element: <p:lst_style>
      class ListStyle < Lutaml::Model::Serializable
          attribute :def_ppr, :string
          attribute :lvl1p_pr, :string
          attribute :lvl2p_pr, :string
          attribute :lvl3p_pr, :string

          xml do
            root 'lst_style'
            namespace 'http://schemas.openxmlformats.org/presentationml/2006/main', 'p'
            mixed_content

            map_element 'defPPr', to: :def_ppr, render_nil: false
            map_element 'lvl1pPr', to: :lvl1p_pr, render_nil: false
            map_element 'lvl2pPr', to: :lvl2p_pr, render_nil: false
            map_element 'lvl3pPr', to: :lvl3p_pr, render_nil: false
          end
      end
    end
  end
end
