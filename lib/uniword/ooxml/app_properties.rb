# frozen_string_literal: true

require 'lutaml/model'
require_relative 'namespaces'

module Uniword
  module Ooxml
    # Represents docProps/app.xml - Extended application properties
    #
    # Uses lutaml-model with XmlNamespace classes for perfect round-trip fidelity.
    # Follows ISO 29500 OOXML specification for extended properties.
    #
    # @example Create app properties
    #   props = AppProperties.new(
    #     application: 'Uniword',
    #     company: 'Acme Corp',
    #     pages: '10'
    #   )
    #
    # @example Serialize to XML
    #   xml = props.to_xml
    #
    # @example Deserialize from XML
    #   props = AppProperties.from_xml(xml_string)
    class AppProperties < Lutaml::Model::Serializable
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
      end

      # Template file name (e.g., 'Normal.dotm')
      # @return [String]
      attribute :template, :string, default: -> { 'Normal.dotm' }

      # Application that created the document
      # @return [String]
      attribute :application, :string, default: -> { 'Uniword' }

      # Company name
      # @return [String, nil]
      attribute :company, :string

      # Application version (e.g., '16.0000' for Office 2016)
      # @return [String]
      attribute :app_version, :string, default: -> { '16.0000' }

      # Number of pages
      # @return [String, nil]
      attribute :pages, :string

      # Word count
      # @return [String, nil]
      attribute :words, :string

      # Character count (without spaces)
      # @return [String, nil]
      attribute :characters, :string

      # Line count
      # @return [String, nil]
      attribute :lines, :string

      # Paragraph count
      # @return [String, nil]
      attribute :paragraphs, :string

      # Character count (with spaces)
      # @return [String, nil]
      attribute :characters_with_spaces, :string

      # Total editing time in minutes
      # @return [String]
      attribute :total_time, :string, default: -> { '0' }

      # Scale crop setting
      # @return [String]
      attribute :scale_crop, :string, default: -> { 'false' }

      # Document security level (0 = none)
      # @return [String]
      attribute :doc_security, :string, default: -> { '0' }

      # Links are up to date flag
      # @return [String]
      attribute :links_up_to_date, :string, default: -> { 'false' }

      # Shared document flag
      # @return [String]
      attribute :shared_doc, :string, default: -> { 'false' }

      # Hyperlinks changed flag
      # @return [String]
      attribute :hyperlinks_changed, :string, default: -> { 'false' }
    end
  end
end
