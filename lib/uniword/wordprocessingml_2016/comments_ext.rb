# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml2016
    # Extended comments properties
    #
    # Generated from OOXML schema: wordprocessingml_2016.yml
    # Element: <w16:commentsExt>
    class CommentsExt < Lutaml::Model::Serializable
      attribute :para_id, :string
      attribute :done, :string

      xml do
        element "commentsExt"
        namespace Uniword::Ooxml::Namespaces::Word2015

        map_attribute "para-id", to: :para_id
        map_attribute "done", to: :done
      end
    end
  end
end
