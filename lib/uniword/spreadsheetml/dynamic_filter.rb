# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Spreadsheetml
    # Dynamic filter (above average, today, etc.)
    #
    # Element: <dynamicFilter>
    class DynamicFilter < Lutaml::Model::Serializable
      attribute :type, :string
      attribute :val, :float
      attribute :max_val, :float

      xml do
        element 'dynamicFilter'
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML

        map_attribute 'type', to: :type
        map_attribute 'val', to: :val, render_nil: false
        map_attribute 'maxVal', to: :max_val, render_nil: false
      end
    end
  end
end
