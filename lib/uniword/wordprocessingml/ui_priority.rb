# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Wordprocessingml
      # UI sort order priority
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:uiPriority>
      class UiPriority < Lutaml::Model::Serializable
          attribute :val, :integer

          xml do
            element 'uiPriority'
            namespace Uniword::Ooxml::Namespaces::WordProcessingML

            map_attribute 'val', to: :val
          end
      end
    end
end
