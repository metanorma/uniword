# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml2010
    # Text outline effect for enhanced typography
    #
    # Generated from OOXML schema: wordprocessingml_2010.yml
    # Element: <w14:textOutline>
    class TextOutline < Lutaml::Model::Serializable
      attribute :width, :integer
      attribute :cap, :string
      attribute :compound, :string
      attribute :align, :string

      xml do
        element 'textOutline'
        namespace Uniword::Ooxml::Namespaces::Word2010

        map_attribute 'width', to: :width
        map_attribute 'cap', to: :cap
        map_attribute 'compound', to: :compound
        map_attribute 'align', to: :align
      end
    end
  end
end
