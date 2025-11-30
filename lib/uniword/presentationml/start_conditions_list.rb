# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Presentationml
    # List of conditions that trigger animation start
    #
    # Generated from OOXML schema: presentationml.yml
    # Element: <p:st_cond_lst>
    class StartConditionsList < Lutaml::Model::Serializable
      attribute :cond, :string, collection: true, default: -> { [] }

      xml do
        element 'st_cond_lst'
        namespace Uniword::Ooxml::Namespaces::PresentationalML
        mixed_content

        map_element 'cond', to: :cond, render_nil: false
      end
    end
  end
end
