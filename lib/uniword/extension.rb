# frozen_string_literal: true

module Uniword
  # Represents a theme family element in extension
  class ThemeFamily < Lutaml::Model::Serializable
    attribute :name, :string
    attribute :id, :string
    attribute :vid, :string

    xml do
      element 'themeFamily'
      namespace Ooxml::Namespaces::DrawingML
      map_attribute 'name', to: :name
      map_attribute 'id', to: :id
      map_attribute 'vid', to: :vid
    end

    def initialize(attributes = {})
      super
      @name ||= ''
      @id ||= ''
      @vid ||= ''
    end
  end

  # Represents an extension element in DrawingML extension list
  #
  # Extensions allow themes to include custom XML extensions.
  class Extension < Lutaml::Model::Serializable
    # Extension URI identifier
    attribute :uri, :string

    # Theme family information (common extension)
    attribute :theme_family, ThemeFamily

    # OOXML namespace configuration
    xml do
      element 'ext'
      namespace Ooxml::Namespaces::DrawingML
      map_attribute 'uri', to: :uri
      map_element 'themeFamily', to: :theme_family
    end

    def initialize(attributes = {})
      super
      @uri ||= ''
    end
  end
end