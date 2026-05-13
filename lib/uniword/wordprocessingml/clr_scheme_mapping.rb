# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    class ClrSchemeMapping < Lutaml::Model::Serializable
      attribute :bg1, :string
      attribute :t1, :string
      attribute :bg2, :string
      attribute :t2, :string
      attribute :accent1, :string
      attribute :accent2, :string
      attribute :accent3, :string
      attribute :accent4, :string
      attribute :accent5, :string
      attribute :accent6, :string
      attribute :hyperlink, :string
      attribute :followed_hyperlink, :string

      xml do
        element "clrSchemeMapping"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute "bg1", to: :bg1
        map_attribute "t1", to: :t1
        map_attribute "bg2", to: :bg2
        map_attribute "t2", to: :t2
        map_attribute "accent1", to: :accent1
        map_attribute "accent2", to: :accent2
        map_attribute "accent3", to: :accent3
        map_attribute "accent4", to: :accent4
        map_attribute "accent5", to: :accent5
        map_attribute "accent6", to: :accent6
        map_attribute "hyperlink", to: :hyperlink
        map_attribute "followedHyperlink", to: :followed_hyperlink
      end
    end
  end
end
