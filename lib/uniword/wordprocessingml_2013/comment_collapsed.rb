# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml2013
    # Comment collapsed state in UI
    #
    # Generated from OOXML schema: wordprocessingml_2013.yml
    # Element: <w15:collapsed>
    class CommentCollapsed < Lutaml::Model::Serializable
      attribute :val, String

      xml do
        element 'collapsed'
        namespace Uniword::Ooxml::Namespaces::Word2012

        map_attribute 'val', to: :val
      end
    end
  end
end
