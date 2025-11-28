# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml
      # Footnote reference marker
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:footnoteReference>
      class FootnoteReference < Lutaml::Model::Serializable
          attribute :id, :string

          xml do
            root 'footnoteReference'
            namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'

            map_attribute 'true', to: :id
          end
      end
    end
  end
end
