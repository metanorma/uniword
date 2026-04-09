# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Ooxml
    # Represents docProps/core.xml - Core document metadata properties
    class CoreProperties < Lutaml::Model::Serializable
      # Use Type classes - namespaces come from Type definitions
      attribute :title, Types::DcTitleType
      attribute :subject, Types::DcSubjectType
      attribute :creator, Types::DcCreatorType
      attribute :keywords, Types::CpKeywordsType
      attribute :description, Types::DcDescriptionType # Dublin Core, not CP!
      attribute :last_modified_by, Types::CpLastModifiedByType
      attribute :revision, Types::CpRevisionType
      attribute :created, Types::DctermsCreatedType
      attribute :modified, Types::DctermsModifiedType

      xml do
        element 'coreProperties'
        namespace Namespaces::CoreProperties

        # Declare all namespaces used by child elements (new lutaml-model syntax)
        namespace_scope [
          { namespace: Namespaces::DublinCore, declare: :always },
          { namespace: Namespaces::DublinCoreTerms, declare: :always },
          { namespace: Namespaces::XmlSchemaInstance, declare: :always }
        ]

        # Type namespaces automatically applied - NO namespace params needed!
        map_element 'title', to: :title,
                             render_nil: :as_blank,
                             render_empty: :as_blank
        map_element 'subject', to: :subject,
                               render_nil: :as_blank,
                               render_empty: :as_blank
        map_element 'creator', to: :creator,
                               render_nil: :as_blank,
                               render_empty: :as_blank
        map_element 'keywords', to: :keywords,
                                render_nil: :as_blank,
                                render_empty: :as_blank
        map_element 'description', to: :description,
                                   render_nil: :as_blank,
                                   render_empty: :as_blank
        map_element 'lastModifiedBy', to: :last_modified_by
        map_element 'revision', to: :revision

        # Nested Models also get namespace from Type declaration automatically
        map_element 'created', to: :created
        map_element 'modified', to: :modified
      end

      def initialize(attributes = {})
        super
        now = DateTime.now
        @created ||= Types::DctermsCreatedType.new(
          value: now,
          type: 'dcterms:W3CDTF'
        )
        @modified ||= Types::DctermsModifiedType.new(
          value: now,
          type: 'dcterms:W3CDTF'
        )
      end
    end
  end
end
