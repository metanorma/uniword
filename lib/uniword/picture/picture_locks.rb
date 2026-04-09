# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Picture
    # Picture locks
    #
    # Generated from OOXML schema: picture.yml
    # Element: <pic:picLocks>
    class PictureLocks < Lutaml::Model::Serializable
      attribute :no_change_aspect, :string
      attribute :no_change_arrowheads, :string

      xml do
        element 'picLocks'
        namespace Uniword::Ooxml::Namespaces::Picture

        map_attribute 'no-change-aspect', to: :no_change_aspect
        map_attribute 'no-change-arrowheads', to: :no_change_arrowheads
      end
    end
  end
end
