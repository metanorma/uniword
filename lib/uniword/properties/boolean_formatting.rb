# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Properties
    # Strike-through formatting
    class Strike < Lutaml::Model::Serializable
      attribute :value, :boolean, default: -> { true }
      xml do
        element 'strike'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute 'val', to: :value, render_nil: false, render_default: false
      end
    end

    # Double strike-through formatting
    class DoubleStrike < Lutaml::Model::Serializable
      attribute :value, :boolean, default: -> { true }
      xml do
        element 'dstrike'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute 'val', to: :value, render_nil: false, render_default: false
      end
    end

    # Small caps formatting
    class SmallCaps < Lutaml::Model::Serializable
      attribute :value, :boolean, default: -> { true }
      xml do
        element 'smallCaps'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute 'val', to: :value, render_nil: false, render_default: false
      end
    end

    # All caps formatting
    class Caps < Lutaml::Model::Serializable
      attribute :value, :boolean, default: -> { true }
      xml do
        element 'caps'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute 'val', to: :value, render_nil: false, render_default: false
      end
    end

    # Hidden text
    class Vanish < Lutaml::Model::Serializable
      attribute :value, :boolean, default: -> { true }
      xml do
        element 'vanish'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute 'val', to: :value, render_nil: false, render_default: false
      end
    end

    # No proofing (disable spell/grammar check)
    class NoProof < Lutaml::Model::Serializable
      attribute :value, :boolean, default: -> { true }
      xml do
        element 'noProof'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute 'val', to: :value, render_nil: false, render_default: false
      end
    end
  end
end
