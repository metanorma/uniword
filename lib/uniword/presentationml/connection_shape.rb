# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Presentationml
    # Connector shape linking two other shapes
    #
    # Generated from OOXML schema: presentationml.yml
    # Element: <p:cxn_sp>
    class ConnectionShape < Lutaml::Model::Serializable
      attribute :nv_cxn_sp_pr, :string
      attribute :sp_pr, ShapeProperties

      xml do
        element 'cxn_sp'
        namespace Uniword::Ooxml::Namespaces::PresentationalML
        mixed_content

        map_element 'nvCxnSpPr', to: :nv_cxn_sp_pr
        map_element 'spPr', to: :sp_pr
      end
    end
  end
end
