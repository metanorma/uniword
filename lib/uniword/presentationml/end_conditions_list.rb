# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Presentationml
    # List of conditions that trigger animation end
    #
    # Generated from OOXML schema: presentationml.yml
    # Element: <p:end_cond_lst>
    class EndConditionsList < Lutaml::Model::Serializable
      attribute :cond, :string, collection: true, initialize_empty: true

      xml do
        element 'end_cond_lst'
        namespace Uniword::Ooxml::Namespaces::PresentationalML
        mixed_content

        map_element 'cond', to: :cond, render_nil: false
      end
    end
  end
end
