# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Vml
      # VML Wrap element
      # Defines text wrapping around shape
      class Wrap < Lutaml::Model::Serializable
        # PATTERN 0: Attributes FIRST
        attribute :anchorx, :string
        attribute :anchory, :string

        xml do
          root 'wrap'
          namespace Uniword::Ooxml::Namespaces::Vml
          mixed_content

          map_attribute 'anchorx', to: :anchorx, render_nil: false
          map_attribute 'anchory', to: :anchory, render_nil: false
        end
      end
    end
  end
end