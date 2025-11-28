# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml
      # Endnote reference marker
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:endnoteReference>
      class EndnoteReference < Lutaml::Model::Serializable
          attribute :id, :string

          xml do
            root 'endnoteReference'
            namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'

            map_attribute 'true', to: :id
          end
      end
    end
  end
end
