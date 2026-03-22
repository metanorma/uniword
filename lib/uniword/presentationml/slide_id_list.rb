# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Presentationml
    # Container for slide identifiers
    #
    # Generated from OOXML schema: presentationml.yml
    # Element: <p:sld_id_lst>
    class SlideIdList < Lutaml::Model::Serializable
      attribute :sld_id, SlideId, collection: true, initialize_empty: true

      xml do
        element 'sld_id_lst'
        namespace Uniword::Ooxml::Namespaces::PresentationalML
        mixed_content

        map_element 'sldId', to: :sld_id, render_nil: false
      end
    end
  end
end
