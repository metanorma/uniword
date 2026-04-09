# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module WpDrawing
    # Drawing object non-visual properties
    #
    # Generated from OOXML schema: wp_drawing.yml
    # Element: <wp:docPr>
    class DocPr < Lutaml::Model::Serializable
      attribute :id, :integer
      attribute :name, :string
      attribute :descr, :string
      attribute :hidden, :string
      attribute :title, :string

      xml do
        element 'docPr'
        namespace Uniword::Ooxml::Namespaces::WordProcessingDrawing

        map_attribute 'id', to: :id
        map_attribute 'name', to: :name
        map_attribute 'descr', to: :descr
        map_attribute 'hidden', to: :hidden
        map_attribute 'title', to: :title
      end
    end
  end
end
