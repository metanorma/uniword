# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Office
    # Diagram rules
    #
    # Generated from OOXML schema: office.yml
    # Element: <o:rules>
    class Rules < Lutaml::Model::Serializable
      attribute :rule, :string, collection: true, initialize_empty: true

      xml do
        element 'rules'
        namespace Uniword::Ooxml::Namespaces::Office

        map_element '', to: :rule, render_nil: false
      end
    end
  end
end
