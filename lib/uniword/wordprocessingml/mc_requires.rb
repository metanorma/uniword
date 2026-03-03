# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Custom type for mc:Requires attribute
    class McRequires < Lutaml::Model::Type::String
      xml_namespace Uniword::Ooxml::Namespaces::MarkupCompatibility
    end
  end
end
