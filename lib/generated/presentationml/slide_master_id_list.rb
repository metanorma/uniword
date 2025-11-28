# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Presentationml
      # Container for slide master identifiers
      #
      # Generated from OOXML schema: presentationml.yml
      # Element: <p:sld_master_id_lst>
      class SlideMasterIdList < Lutaml::Model::Serializable
          attribute :sld_master_id, SlideMasterId, collection: true, default: -> { [] }

          xml do
            root 'sld_master_id_lst'
            namespace 'http://schemas.openxmlformats.org/presentationml/2006/main', 'p'
            mixed_content

            map_element 'sldMasterId', to: :sld_master_id, render_nil: false
          end
      end
    end
  end
end
