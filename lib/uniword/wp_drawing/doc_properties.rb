# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module WpDrawing
    # Document Properties for drawing objects
    class DocProperties < Lutaml::Model::Serializable
      # PATTERN 0: Attributes FIRST
      attribute :id, :string
      attribute :name, :string
      attribute :descr, :string
      attribute :hidden, :string

      xml do
        root 'docPr'
        namespace Uniword::Ooxml::Namespaces::WordProcessingDrawing
        mixed_content

        map_attribute 'id', to: :id, render_nil: false
        map_attribute 'name', to: :name, render_nil: false
        map_attribute 'descr', to: :descr, render_nil: false
        map_attribute 'hidden', to: :hidden, render_nil: false
      end
    end
  end
end