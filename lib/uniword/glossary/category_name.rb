# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Glossary
    # Name of a category
    #
    # Generated from OOXML schema: glossary.yml
    # Element: <g:category_name>
    class CategoryName < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        root 'name'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML

        map_attribute 'val', to: :val
      end
    end
  end
end
