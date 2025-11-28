# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
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
            root 'latentStyles'
            namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'

            map_attribute 'true', to: :defLockedState
            map_attribute 'true', to: :defUIPriority
            map_attribute 'true', to: :defSemiHidden
            map_attribute 'true', to: :defUnhideWhenUsed
            map_attribute 'true', to: :defQFormat
            map_attribute 'true', to: :count
          end
      end
    end
  end
end
