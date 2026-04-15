# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Spreadsheetml
    # Column sort specification
    #
    # Element: <sortCondition>
    class SortCondition < Lutaml::Model::Serializable
      attribute :descending, :string
      attribute :sort_by, :string
      attribute :ref, :string
      attribute :custom_list, :string
      attribute :dxf_id, :string
      attribute :icon_set, :string
      attribute :icon_id, :integer

      xml do
        element "sortCondition"
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML

        map_attribute "descending", to: :descending, render_nil: false
        map_attribute "sortBy", to: :sort_by, render_nil: false
        map_attribute "ref", to: :ref
        map_attribute "customList", to: :custom_list, render_nil: false
        map_attribute "dxfId", to: :dxf_id, render_nil: false
        map_attribute "iconSet", to: :icon_set, render_nil: false
        map_attribute "iconId", to: :icon_id, render_nil: false
      end
    end
  end
end
