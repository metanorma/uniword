# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Presentationml
    # Time node for parallel animation execution
    #
    # Generated from OOXML schema: presentationml.yml
    # Element: <p:par>
    class ParallelTimeNode < Lutaml::Model::Serializable
      attribute :c_tn, CommonTimeNode

      xml do
        element "par"
        namespace Uniword::Ooxml::Namespaces::PresentationalML
        mixed_content

        map_element "cTn", to: :c_tn
      end
    end
  end
end
