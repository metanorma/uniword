# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Presentationml
    # Animation timing information for a slide
    #
    # Generated from OOXML schema: presentationml.yml
    # Element: <p:timing>
    class Timing < Lutaml::Model::Serializable
      attribute :tn_lst, TimeNodeList
      attribute :bld_lst, :string

      xml do
        element "timing"
        namespace Uniword::Ooxml::Namespaces::PresentationalML
        mixed_content

        map_element "tnLst", to: :tn_lst, render_nil: false
        map_element "bldLst", to: :bld_lst, render_nil: false
      end
    end
  end
end
