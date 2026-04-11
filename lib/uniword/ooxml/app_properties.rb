# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Ooxml
    # Wrapper for <HeadingPairs> element containing a <vt:vector>
    class HeadingPairs < Lutaml::Model::Serializable
      attribute :vector, Types::VariantTypes::VtVector

      xml do
        element 'HeadingPairs'
        namespace Namespaces::ExtendedProperties

        map_element 'vector', to: :vector
      end
    end

    # Wrapper for <TitlesOfParts> element containing a <vt:vector>
    class TitlesOfParts < Lutaml::Model::Serializable
      attribute :vector, Types::VariantTypes::VtVector

      xml do
        element 'TitlesOfParts'
        namespace Namespaces::ExtendedProperties

        map_element 'vector', to: :vector
      end
    end

    # Represents docProps/app.xml - Extended application properties
    #
    # Uses lutaml-model with XmlNamespace classes for perfect round-trip fidelity.
    # Follows ISO 29500 OOXML specification for extended properties.
    class AppProperties < Lutaml::Model::Serializable
      # Template file name (e.g., 'Normal.dotm')
      attribute :template, :string, default: -> { 'Normal.dotm' }

      # Application that created the document
      attribute :application, :string, default: -> { 'Uniword' }

      # Company name
      attribute :company, :string

      # Application version (e.g., '16.0000' for Office 2016)
      attribute :app_version, :string, default: -> { '16.0000' }

      # Document statistics
      attribute :pages, :string
      attribute :words, :string
      attribute :characters, :string
      attribute :lines, :string
      attribute :paragraphs, :string
      attribute :characters_with_spaces, :string

      # Editing metadata
      attribute :total_time, :string, default: -> { '0' }
      attribute :scale_crop, :string, default: -> { 'false' }
      attribute :doc_security, :string, default: -> { '0' }
      attribute :links_up_to_date, :string, default: -> { 'false' }
      attribute :shared_doc, :string, default: -> { 'false' }
      attribute :hyperlinks_changed, :string, default: -> { 'false' }

      # Document metadata
      attribute :manager, :string
      attribute :category, :string
      attribute :comments, :string
      attribute :hyperlink_base, :string
      attribute :preview_picture, :string

      # Vector-valued properties (wrappers containing vt:vector)
      attribute :heading_pairs, HeadingPairs
      attribute :titles_of_parts, TitlesOfParts

      # Presentation-specific properties
      attribute :slides, :string
      attribute :hidden_slides, :string
      attribute :notes, :string
      attribute :multimedia_clips, :string
      attribute :presentation_format, :string

      xml do
        element 'Properties'

        # Extended properties namespace
        namespace Namespaces::ExtendedProperties

        # Force vt namespace declaration even though unused
        # This matches Microsoft Word's output format
        namespace_scope [
          { namespace: Namespaces::VariantTypes, declare: :always }
        ]

        # OOXML spec order (ISO 29500)
        map_element 'Template', to: :template
        map_element 'TotalTime', to: :total_time
        map_element 'Pages', to: :pages
        map_element 'Words', to: :words
        map_element 'Characters', to: :characters
        map_element 'Application', to: :application
        map_element 'DocSecurity', to: :doc_security
        map_element 'Lines', to: :lines
        map_element 'Paragraphs', to: :paragraphs
        map_element 'ScaleCrop', to: :scale_crop
        map_element 'Company', to: :company,
                               render_nil: true,
                               value_map: {
                                 from: { empty: :empty },
                                 to: { empty: :empty, nil: :empty }
                               }
        map_element 'LinksUpToDate', to: :links_up_to_date
        map_element 'CharactersWithSpaces', to: :characters_with_spaces
        map_element 'SharedDoc', to: :shared_doc
        map_element 'HyperlinksChanged', to: :hyperlinks_changed
        map_element 'AppVersion', to: :app_version
        map_element 'Manager', to: :manager
        map_element 'Category', to: :category
        map_element 'Comments', to: :comments
        map_element 'HyperlinkBase', to: :hyperlink_base
        map_element 'HeadingPairs', to: :heading_pairs
        map_element 'TitlesOfParts', to: :titles_of_parts
        map_element 'Slides', to: :slides
        map_element 'HiddenSlides', to: :hidden_slides
        map_element 'Notes', to: :notes
        map_element 'MultimediaClips', to: :multimedia_clips
        map_element 'PresentationFormat', to: :presentation_format
      end
    end
  end
end
