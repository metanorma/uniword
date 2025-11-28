# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Presentationml
      # Time node for parallel animation execution
      #
      # Generated from OOXML schema: presentationml.yml
      # Element: <p:par>
      class ParallelTimeNode < Lutaml::Model::Serializable
          attribute :c_tn, CommonTimeNode

          xml do
            root 'par'
            namespace 'http://schemas.openxmlformats.org/presentationml/2006/main', 'p'
            mixed_content

            map_element 'cTn', to: :c_tn
          end
      end
    end
  end
end
