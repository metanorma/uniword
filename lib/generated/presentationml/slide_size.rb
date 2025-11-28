# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Presentationml
      # Dimensions for slides in the presentation
      #
      # Generated from OOXML schema: presentationml.yml
      # Element: <p:sld_sz>
      class SlideSize < Lutaml::Model::Serializable
          attribute :cx, :integer
          attribute :cy, :integer
          attribute :type, :string

          xml do
            root 'sld_sz'
            namespace 'http://schemas.openxmlformats.org/presentationml/2006/main', 'p'

            map_attribute 'cx', to: :cx
            map_attribute 'cy', to: :cy
            map_attribute 'type', to: :type
          end
      end
    end
  end
end
