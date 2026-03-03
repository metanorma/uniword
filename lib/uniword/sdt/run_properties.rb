# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Sdt
    # Run properties for SDT content formatting
    # Reference XML: <w:rPr><w:color w:val="FFFFFF" w:themeColor="background1"/><w:sz w:val="32"/><w:szCs w:val="32"/></w:rPr>
    # This is a wrapper that preserves run properties in SDT context
    # The actual properties will be preserved as raw content since they use the same
    # structure as regular run properties
    class RunProperties < Lutaml::Model::Serializable
      xml do
        element 'rPr'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
      end
    end
  end
end
