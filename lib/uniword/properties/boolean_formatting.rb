# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Properties
    # Strike-through formatting
    class Strike < Lutaml::Model::Serializable
      attribute :value, :boolean
      xml do
        element 'strike'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute 'val', to: :value, render_nil: false, render_default: false
      end
    end

    # Double strike-through formatting
    class DoubleStrike < Lutaml::Model::Serializable
      attribute :value, :boolean
      xml do
        element 'dstrike'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute 'val', to: :value, render_nil: false, render_default: false
      end
    end

    # Small caps formatting
    class SmallCaps < Lutaml::Model::Serializable
      attribute :value, :boolean
      xml do
        element 'smallCaps'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute 'val', to: :value, render_nil: false, render_default: false
      end
    end

    # All caps formatting
    class Caps < Lutaml::Model::Serializable
      attribute :value, :boolean
      xml do
        element 'caps'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute 'val', to: :value, render_nil: false, render_default: false
      end
    end

    # Hidden text
    class Vanish < Lutaml::Model::Serializable
      attribute :value, :boolean
      xml do
        element 'vanish'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute 'val', to: :value, render_nil: false, render_default: false
      end
    end

    # No proofing (disable spell/grammar check)
    class NoProof < Lutaml::Model::Serializable
      attribute :value, :boolean
      xml do
        element 'noProof'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute 'val', to: :value, render_nil: false, render_default: false
      end
    end

    # Shadow formatting
    class Shadow < Lutaml::Model::Serializable
      attribute :value, :boolean
      xml do
        element 'shadow'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute 'val', to: :value, render_nil: false, render_default: false
      end
    end

    # Emboss formatting
    class Emboss < Lutaml::Model::Serializable
      attribute :value, :boolean
      xml do
        element 'emboss'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute 'val', to: :value, render_nil: false, render_default: false
      end
    end

    # Imprint formatting
    class Imprint < Lutaml::Model::Serializable
      attribute :value, :boolean
      xml do
        element 'imprint'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute 'val', to: :value, render_nil: false, render_default: false
      end
    end

    # Style-level boolean elements

    # Quick format flag
    class QuickFormat < Lutaml::Model::Serializable
      attribute :value, :boolean
      xml do
        element 'qFormat'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute 'val', to: :value, render_nil: false, render_default: false
      end
    end

    # Keep with next paragraph
    class KeepNext < Lutaml::Model::Serializable
      attribute :value, :boolean
      xml do
        element 'keepNext'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute 'val', to: :value, render_nil: false, render_default: false
      end
    end

    # Keep lines together
    class KeepLines < Lutaml::Model::Serializable
      attribute :value, :boolean
      xml do
        element 'keepLines'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute 'val', to: :value, render_nil: false, render_default: false
      end
    end
  end
end
