# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml2013
      # Extended comment properties for Word 2013+
      #
      # Generated from OOXML schema: wordprocessingml_2013.yml
      # Element: <w15:commentEx>
      class CommentEx < Lutaml::Model::Serializable
          attribute :para_id, String
          attribute :para_id_parent, String
          attribute :done, String

          xml do
            root 'commentEx'
            namespace 'http://schemas.microsoft.com/office/word/2012/wordml', 'w15'

            map_attribute 'true', to: :para_id
            map_attribute 'true', to: :para_id_parent
            map_attribute 'true', to: :done
          end
      end
    end
  end
end
