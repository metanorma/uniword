# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Presentationml
    # Dimensions for notes pages
    #
    # Generated from OOXML schema: presentationml.yml
    # Element: <p:notes_sz>
    class NotesSize < Lutaml::Model::Serializable
      attribute :cx, :integer
      attribute :cy, :integer

      xml do
        element 'notes_sz'
        namespace Uniword::Ooxml::Namespaces::PresentationalML

        map_attribute 'cx', to: :cx
        map_attribute 'cy', to: :cy
      end
    end
  end
end
