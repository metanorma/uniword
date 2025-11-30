# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml2013
    # Footnote column layout
    #
    # Generated from OOXML schema: wordprocessingml_2013.yml
    # Element: <w15:footnoteColumns>
    class FootnoteColumns < Lutaml::Model::Serializable
      attribute :val, Integer

      xml do
        element 'footnoteColumns'
        namespace Uniword::Ooxml::Namespaces::Word2012

        map_attribute 'val', to: :val
      end
    end
  end
end
