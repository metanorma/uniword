# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    # Use East Asian Layout compatibility (empty marker element)
    #
    # Element: <w:useFELayout>
    class UseFELayout < Lutaml::Model::Serializable
      xml do
        element "useFELayout"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
      end
    end

    # Compatibility settings
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:compat>
    class Compat < Lutaml::Model::Serializable
      attribute :use_fe_layout, UseFELayout
      attribute :compatSetting, CompatSetting, collection: true,
                                               initialize_empty: true

      xml do
        element "compat"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        map_element "useFELayout", to: :use_fe_layout, render_nil: false
        map_element "compatSetting", to: :compatSetting, render_nil: false
      end
    end
  end
end
