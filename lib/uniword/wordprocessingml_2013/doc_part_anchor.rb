# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml2013
    # Document part anchor for content positioning
    #
    # Generated from OOXML schema: wordprocessingml_2013.yml
    # Element: <w15:docPartAnchor>
    class DocPartAnchor < Lutaml::Model::Serializable
      attribute :val, String

      xml do
        element 'docPartAnchor'
        namespace Uniword::Ooxml::Namespaces::Word2012

        map_attribute 'val', to: :val
      end
    end
  end
end
