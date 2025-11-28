# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml
      # Drawing object non-visual properties
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:docPr>
      class DocPr < Lutaml::Model::Serializable
          attribute :id, :integer
          attribute :name, :string
          attribute :descr, :string

          xml do
            root 'docPr'
            namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'

            map_attribute 'true', to: :id
            map_attribute 'true', to: :name
            map_attribute 'true', to: :descr
          end
      end
    end
  end
end
