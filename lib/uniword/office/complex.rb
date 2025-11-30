# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Office
    # Complex property
    #
    # Generated from OOXML schema: office.yml
    # Element: <o:complex>
    class Complex < Lutaml::Model::Serializable
      attribute :ext, :string

      xml do
        element 'complex'
        namespace Uniword::Ooxml::Namespaces::Office

        map_attribute 'ext', to: :ext
      end
    end
  end
end
