# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Spreadsheetml
    # Icon filter criteria
    #
    # Element: <iconFilter>
    class IconFilter < Lutaml::Model::Serializable
      attribute :icon_set, :string
      attribute :icon_id, :integer

      xml do
        element "iconFilter"
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML

        map_attribute "iconSet", to: :icon_set, render_nil: false
        map_attribute "iconId", to: :icon_id, render_nil: false
      end
    end
  end
end
