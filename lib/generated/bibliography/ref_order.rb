# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Bibliography
      # Reference order in bibliography
      #
      # Generated from OOXML schema: bibliography.yml
      # Element: <b:ref_order>
      class RefOrder < Lutaml::Model::Serializable
          attribute :val, :integer

          xml do
            root 'ref_order'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/bibliography', 'b'

            map_attribute 'val', to: :val
          end
      end
    end
  end
end
