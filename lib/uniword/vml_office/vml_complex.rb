# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module VmlOffice
    # Complex VML property for advanced features
    #
    # Generated from OOXML schema: vml_office.yml
    # Element: <o:complex>
    class VmlComplex < Lutaml::Model::Serializable
      attribute :ext, String

      xml do
        element 'complex'
        namespace Uniword::Ooxml::Namespaces::Vml

        map_attribute 'ext', to: :ext
      end
    end
  end
end
