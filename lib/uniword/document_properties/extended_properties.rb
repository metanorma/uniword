# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module DocumentProperties
    # Root element for extended properties
    #
    # Generated from OOXML schema: document_properties.yml
    # Element: <ep:Properties>
    class ExtendedProperties < Lutaml::Model::Serializable
      attribute :application, :string
      attribute :doc_security, :string
      attribute :scale_crop, :string
      attribute :heading_pairs, HeadingPairs
      attribute :titles_of_parts, TitlesOfParts
      attribute :company, :string
      attribute :links_up_to_date, :string
      attribute :shared_doc, :string
      attribute :hyperlinks_changed, :string
      attribute :app_version, :string

      xml do
        element 'Properties'
        namespace Uniword::Ooxml::Namespaces::ExtendedProperties
        mixed_content

        map_element 'Application', to: :application, render_nil: false
        map_element 'DocSecurity', to: :doc_security, render_nil: false
        map_element 'ScaleCrop', to: :scale_crop, render_nil: false
        map_element 'HeadingPairs', to: :heading_pairs, render_nil: false
        map_element 'TitlesOfParts', to: :titles_of_parts, render_nil: false
        map_element 'Company', to: :company, render_nil: false
        map_element 'LinksUpToDate', to: :links_up_to_date, render_nil: false
        map_element 'SharedDoc', to: :shared_doc, render_nil: false
        map_element 'HyperlinksChanged', to: :hyperlinks_changed, render_nil: false
        map_element 'AppVersion', to: :app_version, render_nil: false
      end
    end
  end
end
