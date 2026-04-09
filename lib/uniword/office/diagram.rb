# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Office
    # Diagram container
    #
    # Generated from OOXML schema: office.yml
    # Element: <o:diagram>
    class Diagram < Lutaml::Model::Serializable
      attribute :dgmstyle, :string
      attribute :autoformat, :string
      attribute :reverse, :string
      attribute :autolayout, :string
      attribute :dgmscalex, :string
      attribute :dgmscaley, :string
      attribute :dgmfontsize, :string
      attribute :constrainbounds, :string

      xml do
        element 'diagram'
        namespace Uniword::Ooxml::Namespaces::Office

        map_attribute 'dgmstyle', to: :dgmstyle
        map_attribute 'autoformat', to: :autoformat
        map_attribute 'reverse', to: :reverse
        map_attribute 'autolayout', to: :autolayout
        map_attribute 'dgmscalex', to: :dgmscalex
        map_attribute 'dgmscaley', to: :dgmscaley
        map_attribute 'dgmfontsize', to: :dgmfontsize
        map_attribute 'constrainbounds', to: :constrainbounds
      end
    end
  end
end
