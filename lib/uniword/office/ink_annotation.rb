# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Office
    # Ink annotation properties
    #
    # Generated from OOXML schema: office.yml
    # Element: <o:inkannotation>
    class InkAnnotation < Lutaml::Model::Serializable
      attribute :author, :string
      attribute :date, :string

      xml do
        element 'inkannotation'
        namespace Uniword::Ooxml::Namespaces::Office

        map_attribute 'author', to: :author
        map_attribute 'date', to: :date
      end
    end
  end
end
