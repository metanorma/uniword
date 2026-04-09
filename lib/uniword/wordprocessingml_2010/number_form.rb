# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml2010
    # Number form for advanced typography
    #
    # Generated from OOXML schema: wordprocessingml_2010.yml
    # Element: <w14:numForm>
    class NumberForm < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element 'numForm'
        namespace Uniword::Ooxml::Namespaces::Word2010

        map_attribute 'val', to: :val
      end
    end
  end
end
