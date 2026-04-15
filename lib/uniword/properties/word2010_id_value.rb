# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Properties
    # Namespaced custom type for Word 2010 (wp14) attributes
    # Used for wp14:anchorId and wp14:editId attributes
    class Word2010IdValue < Lutaml::Model::Type::String
      include Lutaml::Xml::Type::Configurable

      xml do
        namespace Uniword::Ooxml::Namespaces::Word2010
      end
    end
  end
end
