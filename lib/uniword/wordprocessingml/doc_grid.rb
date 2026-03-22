# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Document grid settings
    #
    # Element: <w:docGrid>
    class DocGrid < Lutaml::Model::Serializable
      attribute :line_pitch, :integer
      attribute :type, :string
      attribute :character_pitch, :integer

      xml do
        element 'docGrid'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML

        map_attribute 'linePitch', to: :line_pitch
        map_attribute 'type', to: :type
        map_attribute 'charPitch', to: :character_pitch
      end
    end
  end
end
