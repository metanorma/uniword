# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml2016
    # Enhanced conflict resolution mode
    #
    # Generated from OOXML schema: wordprocessingml_2016.yml
    # Element: <w16:conflictMode>
    class ConflictMode2016 < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element 'conflictMode'
        namespace Uniword::Ooxml::Namespaces::Word2015

        map_attribute 'val', to: :val
      end
    end
  end
end
