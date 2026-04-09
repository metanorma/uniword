# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Cell-level margins wrapper
    # XML: <w:tcMar><w:top w:w="..." .../></w:tcMar>
    class TableCellMargin < Lutaml::Model::Serializable
      attribute :top, Uniword::Properties::Margin
      attribute :start, Uniword::Properties::Margin
      attribute :bottom, Uniword::Properties::Margin
      attribute :left, Uniword::Properties::Margin
      attribute :right, Uniword::Properties::Margin

      xml do
        element 'tcMar'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        map_element 'top', to: :top, render_nil: false
        map_element 'start', to: :start, render_nil: false
        map_element 'bottom', to: :bottom, render_nil: false
        map_element 'left', to: :left, render_nil: false
        map_element 'right', to: :right, render_nil: false
      end
    end
  end
end
