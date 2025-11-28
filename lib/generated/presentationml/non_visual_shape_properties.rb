# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Presentationml
      # Non-visual properties for shapes (ID, name, etc.)
      #
      # Generated from OOXML schema: presentationml.yml
      # Element: <p:nv_sp_pr>
      class NonVisualShapeProperties < Lutaml::Model::Serializable
          attribute :c_nv_pr, :string
          attribute :c_nv_sp_pr, :string
          attribute :nv_pr, :string

          xml do
            root 'nv_sp_pr'
            namespace 'http://schemas.openxmlformats.org/presentationml/2006/main', 'p'
            mixed_content

            map_element 'cNvPr', to: :c_nv_pr
            map_element 'cNvSpPr', to: :c_nv_sp_pr
            map_element 'nvPr', to: :nv_pr
          end
      end
    end
  end
end
