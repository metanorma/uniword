# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Glossary
    # Style identifier reference for document parts
    #
    # Generated from OOXML schema: glossary.yml
    # Element: <g:style_id>
    class StyleId < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element 'style_id'
        namespace Uniword::Ooxml::Namespaces::Glossary

        map_attribute 'val', to: :val
      end
    end
  end
end
