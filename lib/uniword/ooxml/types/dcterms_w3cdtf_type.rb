# frozen_string_literal: true

require 'lutaml/model'
require_relative '../namespaces'

module Uniword
  module Ooxml
    module Types
      # xsi:type attribute type
      class XsiTypeType < Lutaml::Model::Type::String
        xml_namespace Namespaces::XmlSchemaInstance
      end

      # Dublin Core Terms created timestamp Model
      class DctermsCreatedType < Lutaml::Model::Serializable
        attribute :value, :date_time
        attribute :type, XsiTypeType

        xml do
          element 'created'
          namespace Namespaces::DublinCoreTerms
          map_attribute 'type', to: :type
          map_content to: :value
        end

        def initialize(attributes = {})
          super
          @type ||= 'dcterms:W3CDTF'
        end
      end

      # Dublin Core Terms modified timestamp Model
      class DctermsModifiedType < Lutaml::Model::Serializable
        attribute :value, :date_time
        attribute :type, XsiTypeType

        xml do
          element 'modified'
          namespace Namespaces::DublinCoreTerms
          map_attribute 'type', to: :type
          map_content to: :value
        end

        def initialize(attributes = {})
          super
          @type ||= 'dcterms:W3CDTF'
        end
      end
    end
  end
end
