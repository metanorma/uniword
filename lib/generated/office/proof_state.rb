# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Office
      # Proof state
      #
      # Generated from OOXML schema: office.yml
      # Element: <o:proofstate>
      class ProofState < Lutaml::Model::Serializable
          attribute :spelling, String
          attribute :grammar, String

          xml do
            root 'proofstate'
            namespace 'urn:schemas-microsoft-com:office:office', 'o'

            map_attribute 'true', to: :spelling
            map_attribute 'true', to: :grammar
          end
      end
    end
  end
end
