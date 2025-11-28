# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Picture
      # Picture locks
      #
      # Generated from OOXML schema: picture.yml
      # Element: <pic:picLocks>
      class PictureLocks < Lutaml::Model::Serializable
          attribute :no_change_aspect, String
          attribute :no_change_arrowheads, String

          xml do
            root 'picLocks'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/picture', 'pic'

            map_attribute 'true', to: :no_change_aspect
            map_attribute 'true', to: :no_change_arrowheads
          end
      end
    end
  end
end
