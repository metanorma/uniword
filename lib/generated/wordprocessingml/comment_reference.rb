# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml
      # Comment reference marker
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:commentReference>
      class CommentReference < Lutaml::Model::Serializable
          attribute :id, :string

          xml do
            root 'commentReference'
            namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'

            map_attribute 'true', to: :id
          end
      end
    end
  end
end
