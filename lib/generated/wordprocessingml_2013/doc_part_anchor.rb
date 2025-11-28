# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml2013
      # Document part anchor for content positioning
      #
      # Generated from OOXML schema: wordprocessingml_2013.yml
      # Element: <w15:docPartAnchor>
      class DocPartAnchor < Lutaml::Model::Serializable
          attribute :val, String

          xml do
            root 'docPartAnchor'
            namespace 'http://schemas.microsoft.com/office/word/2012/wordml', 'w15'

            map_attribute 'true', to: :val
          end
      end
    end
  end
end
