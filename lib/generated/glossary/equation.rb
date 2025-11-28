# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Glossary
      # Equation flag for document parts
      #
      # Generated from OOXML schema: glossary.yml
      # Element: <g:equation>
      class Equation < Lutaml::Model::Serializable
          attribute :val, :boolean

          xml do
            root 'equation'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/glossary', 'g'

            map_attribute 'val', to: :val
          end
      end
    end
  end
end
