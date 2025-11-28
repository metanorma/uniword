# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Glossary
      # Style identifier reference for document parts
      #
      # Generated from OOXML schema: glossary.yml
      # Element: <g:style_id>
      class StyleId < Lutaml::Model::Serializable
          attribute :val, :string

          xml do
            root 'style_id'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/glossary', 'g'

            map_attribute 'val', to: :val
          end
      end
    end
  end
end
