# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Presentationml
    # Notes slide for speaker notes
    #
    # Generated from OOXML schema: presentationml.yml
    # Element: <p:notes>
    class Notes < Lutaml::Model::Serializable
      attribute :c_sld, CommonSlideData
      attribute :clr_map_ovr, :string
      attribute :show_master_sp, :string

      xml do
        element "notes"
        namespace Uniword::Ooxml::Namespaces::PresentationalML
        mixed_content

        map_element "cSld", to: :c_sld
        map_element "clrMapOvr", to: :clr_map_ovr, render_nil: false
        map_attribute "showMasterSp", to: :show_master_sp
      end
    end
  end
end
