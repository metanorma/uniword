# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Properties
    # Namespaced custom type for history attribute
    # Used for w:history attribute which belongs to the WordProcessingML namespace
    class HistoryValue < Lutaml::Model::Type::String
      include Lutaml::Xml::Type::Configurable

      xml do
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
      end
    end
  end
end
