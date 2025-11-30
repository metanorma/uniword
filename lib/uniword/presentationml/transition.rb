# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Presentationml
      # Slide transition effect
      #
      # Generated from OOXML schema: presentationml.yml
      # Element: <p:transition>
      class Transition < Lutaml::Model::Serializable
          attribute :spd, :string
          attribute :advTm, :integer
          attribute :fade, :string
          attribute :push, :string
          attribute :wipe, :string
          attribute :split, :string

          xml do
            element 'transition'
            namespace Uniword::Ooxml::Namespaces::PresentationalML
            mixed_content

            map_attribute 'spd', to: :spd
            map_attribute 'advTm', to: :advTm
            map_element 'fade', to: :fade, render_nil: false
            map_element 'push', to: :push, render_nil: false
            map_element 'wipe', to: :wipe, render_nil: false
            map_element 'split', to: :split, render_nil: false
          end
      end
    end
end
