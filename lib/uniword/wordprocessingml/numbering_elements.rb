# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    # Numbering style ID
    #
    # Element: <w:nsid>
    class Nsid < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element "nsid"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute "val", to: :val
      end
    end

    # Numbering template
    #
    # Element: <w:tmpl>
    class Tmpl < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element "tmpl"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute "val", to: :val
      end
    end

    # Indentation for numbering level
    #
    # Element: <w:ind>
    class Ind < Lutaml::Model::Serializable
      attribute :left, :string
      attribute :hanging, :string

      xml do
        element "ind"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute "left", to: :left
        map_attribute "hanging", to: :hanging
      end
    end

    # Run fonts for numbering
    #
    # Element: <w:rFonts>
    class RFonts < Lutaml::Model::Serializable
      attribute :ascii, :string
      attribute :h_ansi, :string
      attribute :hint, :string

      xml do
        element "rFonts"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute "ascii", to: :ascii
        map_attribute "hAnsi", to: :h_ansi
        map_attribute "hint", to: :hint
      end
    end

    # Abstract numbering ID reference
    #
    # Element: <w:abstractNumId>
    class AbstractNumId < Lutaml::Model::Serializable
      attribute :val, :integer

      xml do
        element "abstractNumId"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute "val", to: :val
      end
    end
  end
end
