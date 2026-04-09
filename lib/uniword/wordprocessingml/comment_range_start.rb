# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Comment range start marker
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:commentRangeStart>
    class CommentRangeStart < Lutaml::Model::Serializable
      attribute :id, :string

      xml do
        element 'commentRangeStart'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML

        map_attribute 'id', to: :id
      end
    end
  end
end
