# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Presentationml
      # List of conditions that trigger animation end
      #
      # Generated from OOXML schema: presentationml.yml
      # Element: <p:end_cond_lst>
      class EndConditionsList < Lutaml::Model::Serializable
          attribute :cond, :string, collection: true, default: -> { [] }

          xml do
            root 'end_cond_lst'
            namespace 'http://schemas.openxmlformats.org/presentationml/2006/main', 'p'
            mixed_content

            map_element 'cond', to: :cond, render_nil: false
          end
      end
    end
  end
end
