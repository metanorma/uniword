# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Properties
    # Font family element for run properties
    #
    # Represents <w:rFonts> with ascii, hAnsi, eastAsia, cs, hint attributes
    class RunFonts < Lutaml::Model::Serializable
      # Pattern 0: ATTRIBUTES FIRST
      attribute :ascii, :string
      attribute :h_ansi, :string
      attribute :east_asia, :string
      attribute :cs, :string
      attribute :hint, :string

      xml do
        element 'rFonts'
        namespace Ooxml::Namespaces::WordProcessingML

        map_attribute 'ascii', to: :ascii
        map_attribute 'hAnsi', to: :h_ansi
        map_attribute 'eastAsia', to: :east_asia
        map_attribute 'cs', to: :cs
        map_attribute 'hint', to: :hint
      end
    end
  end
end