# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml2013
    # Document part reference for building blocks
    #
    # Generated from OOXML schema: wordprocessingml_2013.yml
    # Element: <w15:docPart>
    class DocumentPart < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element 'docPart'
        namespace Uniword::Ooxml::Namespaces::Word2012

        map_attribute 'val', to: :val
      end
    end
  end
end
