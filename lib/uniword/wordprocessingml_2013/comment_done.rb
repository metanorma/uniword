# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml2013
    # Comment done/resolved flag
    #
    # Generated from OOXML schema: wordprocessingml_2013.yml
    # Element: <w15:done>
    class CommentDone < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element 'done'
        namespace Uniword::Ooxml::Namespaces::Word2012

        map_attribute 'val', to: :val
      end
    end
  end
end
