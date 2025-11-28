# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Glossary
      # Name of a category
      #
      # Generated from OOXML schema: glossary.yml
      # Element: <g:category_name>
      class CategoryName < Lutaml::Model::Serializable
          attribute :val, :string

          xml do
            root 'category_name'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/glossary', 'g'

            map_attribute 'val', to: :val
          end
      end
    end
  end
end
