# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module VmlOffice
    # VML diagram container
    #
    # Generated from OOXML schema: vml_office.yml
    # Element: <o:diagram>
    class VmlDiagram < Lutaml::Model::Serializable
      attribute :dgmstyle, String
      attribute :autoformat, String
      attribute :reverse, String
      attribute :autolayout, String
      attribute :dgmscalex, String
      attribute :dgmscaley, String

      xml do
        element 'diagram'
        namespace Uniword::Ooxml::Namespaces::Vml

        map_attribute 'dgmstyle', to: :dgmstyle
        map_attribute 'autoformat', to: :autoformat
        map_attribute 'reverse', to: :reverse
        map_attribute 'autolayout', to: :autolayout
        map_attribute 'dgmscalex', to: :dgmscalex
        map_attribute 'dgmscaley', to: :dgmscaley
      end
    end
  end
end
