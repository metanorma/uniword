# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml2010
    # Conditional formatting style reference
    #
    # Generated from OOXML schema: wordprocessingml_2010.yml
    # Element: <w14:cnfStyle>
    class ConditionalFormatStyle < Lutaml::Model::Serializable
      attribute :val, :string
      attribute :first_row, :string
      attribute :last_row, :string
      attribute :first_column, :string
      attribute :last_column, :string

      xml do
        element 'cnfStyle'
        namespace Uniword::Ooxml::Namespaces::Word2010

        map_attribute 'val', to: :val
        map_attribute 'first-row', to: :first_row
        map_attribute 'last-row', to: :last_row
        map_attribute 'first-column', to: :first_column
        map_attribute 'last-column', to: :last_column
      end
    end
  end
end
