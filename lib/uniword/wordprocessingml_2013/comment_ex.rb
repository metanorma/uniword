# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml2013
    # Extended comment properties for Word 2013+
    #
    # Generated from OOXML schema: wordprocessingml_2013.yml
    # Element: <w15:commentEx>
    class CommentEx < Lutaml::Model::Serializable
      attribute :para_id, :string
      attribute :para_id_parent, :string
      attribute :done, :string

      xml do
        element 'commentEx'
        namespace Uniword::Ooxml::Namespaces::Word2012

        map_attribute 'para-id', to: :para_id
        map_attribute 'para-id-parent', to: :para_id_parent
        map_attribute 'done', to: :done
      end
    end
  end
end
