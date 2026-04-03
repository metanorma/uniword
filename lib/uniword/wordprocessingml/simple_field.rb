# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Simple field
    #
    # Element: <w:fldSimple>
    # Represents a simple field with an instruction and optional run content.
    class SimpleField < Lutaml::Model::Serializable
      attribute :instr, :string
      attribute :properties, RunProperties
      attribute :runs, Run, collection: true, initialize_empty: true

      xml do
        element 'fldSimple'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        map_attribute 'instr', to: :instr, render_nil: false
        map_element 'rPr', to: :properties, render_nil: false
        map_element 'r', to: :runs, render_nil: false
      end
    end
  end
end
