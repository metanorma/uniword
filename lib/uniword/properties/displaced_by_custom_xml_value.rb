# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Properties
    # Namespaced custom type for displacedByCustomXml attribute
    # Used for w14:displacedByCustomXml attribute which indicates
    # that a bookmark was displaced by custom XML
    class DisplacedByCustomXmlValue < Lutaml::Model::Type::String
      include Lutaml::Xml::Type::Configurable

      xml do
        namespace Uniword::Ooxml::Namespaces::Word2010
      end
    end
  end
end
