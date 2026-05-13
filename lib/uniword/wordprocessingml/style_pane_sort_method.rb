# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    # Style pane sort method
    #
    # Element: <w:stylePaneSortMethod>
    class StylePaneSortMethod < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element "stylePaneSortMethod"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute "val", to: :val
      end
    end
  end
end
