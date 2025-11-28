# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Presentationml
      # Container for slide identifiers
      #
      # Generated from OOXML schema: presentationml.yml
      # Element: <p:sld_id_lst>
      class SlideIdList < Lutaml::Model::Serializable
          attribute :sld_id, SlideId, collection: true, default: -> { [] }

          xml do
            root 'sld_id_lst'
            namespace 'http://schemas.openxmlformats.org/presentationml/2006/main', 'p'
            mixed_content

            map_element 'sldId', to: :sld_id, render_nil: false
          end
      end
    end
  end
end
