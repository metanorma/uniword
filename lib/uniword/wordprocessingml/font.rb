# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    # AltName element
    class AltName < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element "altName"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute "val", to: :val
      end
    end

    # Panose1 element
    class Panose1 < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element "panose1"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute "val", to: :val
      end
    end

    # Charset element
    class Charset < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element "charset"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute "val", to: :val
      end
    end

    # Family element
    class Family < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element "family"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute "val", to: :val
      end
    end

    # Pitch element
    class Pitch < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element "pitch"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute "val", to: :val
      end
    end

    # Sig element (font signature)
    class Sig < Lutaml::Model::Serializable
      attribute :usb0, :string
      attribute :usb1, :string
      attribute :usb2, :string
      attribute :usb3, :string
      attribute :csb0, :string
      attribute :csb1, :string

      xml do
        element "sig"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute "usb0", to: :usb0
        map_attribute "usb1", to: :usb1
        map_attribute "usb2", to: :usb2
        map_attribute "usb3", to: :usb3
        map_attribute "csb0", to: :csb0
        map_attribute "csb1", to: :csb1
      end
    end

    # Font definition with child elements
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:font>
    class Font < Lutaml::Model::Serializable
      attribute :name, :string
      attribute :alt_name, AltName
      attribute :panose1, Panose1
      attribute :charset, Charset
      attribute :family, Family
      attribute :pitch, Pitch
      attribute :sig, Sig

      xml do
        element "font"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML

        map_attribute "name", to: :name
        map_element "altName", to: :alt_name
        map_element "panose1", to: :panose1
        map_element "charset", to: :charset
        map_element "family", to: :family
        map_element "pitch", to: :pitch
        map_element "sig", to: :sig
      end
    end
  end
end
