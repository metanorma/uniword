# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml
      # UI sort order priority
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:uiPriority>
      class UiPriority < Lutaml::Model::Serializable
          attribute :val, :integer

          xml do
            root 'uiPriority'
            namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'

            map_attribute 'true', to: :val
          end
      end
    end
  end
end
