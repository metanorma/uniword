# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Math
    # Phantom formatting properties
    #
    # Generated from OOXML schema: math.yml
    # Element: <m:phantPr>
    class PhantomProperties < Lutaml::Model::Serializable
      attribute :show, MathSimpleVal
      attribute :zero_wid, MathSimpleVal
      attribute :zero_asc, MathSimpleVal
      attribute :zero_desc, MathSimpleVal
      attribute :transp, MathSimpleVal
      attribute :ctrl_pr, ControlProperties

      xml do
        element 'phantPr'
        namespace Uniword::Ooxml::Namespaces::MathML
        mixed_content

        map_element 'show', to: :show, render_nil: false
        map_element 'zeroWid', to: :zero_wid, render_nil: false
        map_element 'zeroAsc', to: :zero_asc, render_nil: false
        map_element 'zeroDesc', to: :zero_desc, render_nil: false
        map_element 'transp', to: :transp, render_nil: false
        map_element 'ctrlPr', to: :ctrl_pr, render_nil: false
      end
    end
  end
end
