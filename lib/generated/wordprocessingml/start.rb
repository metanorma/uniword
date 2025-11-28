# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml
      # Numbering start value
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:start>
      class Start < Lutaml::Model::Serializable
          attribute :val, :integer

          xml do
            root 'start'
            namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'

            map_attribute 'true', to: :val
          end
      end
    end
  end
end
