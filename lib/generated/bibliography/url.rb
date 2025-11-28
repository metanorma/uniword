# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Bibliography
      # Web URL for online sources
      #
      # Generated from OOXML schema: bibliography.yml
      # Element: <b:url>
      class Url < Lutaml::Model::Serializable
          attribute :val, :string

          xml do
            root 'url'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/bibliography', 'b'

            map_attribute 'val', to: :val
          end
      end
    end
  end
end
