# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Office
      # Diagram rules
      #
      # Generated from OOXML schema: office.yml
      # Element: <o:rules>
      class Rules < Lutaml::Model::Serializable
          attribute :rule, String, collection: true, default: -> { [] }

          xml do
            root 'rules'
            namespace 'urn:schemas-microsoft-com:office:office', 'o'

            map_element '', to: :rule, render_nil: false
          end
      end
    end
  end
end
