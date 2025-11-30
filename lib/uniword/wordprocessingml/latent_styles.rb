# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Wordprocessingml
      # Latent style exception
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:latentStyles>
      class LatentStyles < Lutaml::Model::Serializable
          attribute :defLockedState, :boolean
          attribute :defUIPriority, :integer
          attribute :defSemiHidden, :boolean
          attribute :defUnhideWhenUsed, :boolean
          attribute :defQFormat, :boolean
          attribute :count, :integer

          xml do
            element 'latentStyles'
            namespace Uniword::Ooxml::Namespaces::WordProcessingML

            map_attribute 'defLockedState', to: :defLockedState
            map_attribute 'defUIPriority', to: :defUIPriority
            map_attribute 'defSemiHidden', to: :defSemiHidden
            map_attribute 'defUnhideWhenUsed', to: :defUnhideWhenUsed
            map_attribute 'defQFormat', to: :defQFormat
            map_attribute 'count', to: :count
          end
      end
    end
end
