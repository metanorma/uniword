# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Customxml
    # Flag indicating whether placeholder is displayed
    #
    # Generated from OOXML schema: customxml.yml
    # Element: <cxml:showing_plc_hdr>
    class ShowingPlaceholder < Lutaml::Model::Serializable
      include Uniword::Properties::BooleanElement
      attribute :val, :string, default: nil
      include Uniword::Properties::BooleanValSetter

      xml do
        element 'showing_plc_hdr'
        namespace Uniword::Ooxml::Namespaces::CustomXml
        map_attribute 'val', to: :val, render_nil: false, render_default: false
      end
    end
  end
end
