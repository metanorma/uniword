# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Office
      # Ink annotation properties
      #
      # Generated from OOXML schema: office.yml
      # Element: <o:inkannotation>
      class InkAnnotation < Lutaml::Model::Serializable
          attribute :author, String
          attribute :date, String

          xml do
            root 'inkannotation'
            namespace 'urn:schemas-microsoft-com:office:office', 'o'

            map_attribute 'true', to: :author
            map_attribute 'true', to: :date
          end
      end
    end
  end
end
