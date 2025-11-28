# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml
      # Comment range start marker
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:commentRangeStart>
      class CommentRangeStart < Lutaml::Model::Serializable
          attribute :id, :string

          xml do
            root 'commentRangeStart'
            namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'

            map_attribute 'true', to: :id
          end
      end
    end
  end
end
