# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Spreadsheetml
    # Cell Style
    #
    # Complex type for a named cell style in a workbook.
    class CellStyle < Lutaml::Model::Serializable
      attribute :name, :string
      attribute :xf_id, :integer
      attribute :builtin_id, :integer
      attribute :i_level, :integer
      attribute :hidden, :string
      attribute :custom_builtin, :string

      xml do
        element 'cellStyle'
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML

        map_attribute 'name', to: :name, render_nil: false
        map_attribute 'xfId', to: :xf_id
        map_attribute 'builtinId', to: :builtin_id, render_nil: false
        map_attribute 'iLevel', to: :i_level, render_nil: false
        map_attribute 'hidden', to: :hidden, render_nil: false
        map_attribute 'customBuiltin', to: :custom_builtin, render_nil: false
      end
    end
  end
end
