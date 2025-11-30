# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Compatibility settings
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:compat>
    class Compat < Lutaml::Model::Serializable
      attribute :compatSetting, CompatSetting, collection: true, default: -> { [] }

      xml do
        element 'compat'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        map_element 'compatSetting', to: :compatSetting, render_nil: false
      end
    end
  end
end
