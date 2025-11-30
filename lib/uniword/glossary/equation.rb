# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Glossary
    # Equation flag for document parts
    #
    # Generated from OOXML schema: glossary.yml
    # Element: <g:equation>
    class Equation < Lutaml::Model::Serializable
      attribute :val, :boolean

      xml do
        element 'equation'
        namespace Uniword::Ooxml::Namespaces::Glossary

        map_attribute 'val', to: :val
      end
    end
  end
end
