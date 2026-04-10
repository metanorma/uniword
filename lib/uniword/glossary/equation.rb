# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Glossary
    # Equation flag for document parts
    #
    # Generated from OOXML schema: glossary.yml
    # Element: <g:equation>
    class Equation < Lutaml::Model::Serializable
      include Uniword::Properties::BooleanElement

      attribute :val, :string, default: nil
      include Uniword::Properties::BooleanValSetter

      xml do
        element 'equation'
        namespace Uniword::Ooxml::Namespaces::Glossary
        map_attribute 'val', to: :val, render_nil: false, render_default: false
      end
    end
  end
end
