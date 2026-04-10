# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Mhtml
    module Metadata
      # o:DocumentProperties — Word document metadata from MHTML.
      #
      # Embedded in HTML head as:
      #   <!--[if gte mso 9]><xml>
      #     <o:DocumentProperties>
      #       <o:Author>...</o:Author>
      #       <o:Created>...</o:Created>
      #       ...
      #     </o:DocumentProperties>
      #   </xml><![endif]-->
      class DocumentProperties < Lutaml::Model::Serializable
        attribute :author, :string
        attribute :last_author, :string
        attribute :revision, :string
        attribute :total_time, :string
        attribute :created, :string
        attribute :last_saved, :string
        attribute :pages, :string
        attribute :words, :string
        attribute :characters, :string
        attribute :application, :string
        attribute :doc_security, :string
        attribute :lines, :string
        attribute :paragraphs, :string
        attribute :bytes, :string
        attribute :category, :string
        attribute :presentation_format, :string
        attribute :manager, :string
        attribute :company, :string
        attribute :version, :string

        xml do
          element 'DocumentProperties'
          namespace Uniword::Mhtml::Namespaces::Office
          map_element 'Author', to: :author
          map_element 'LastAuthor', to: :last_author
          map_element 'Revision', to: :revision
          map_element 'TotalTime', to: :total_time
          map_element 'Created', to: :created
          map_element 'LastSaved', to: :last_saved
          map_element 'Pages', to: :pages
          map_element 'Words', to: :words
          map_element 'Characters', to: :characters
          map_element 'Application', to: :application
          map_element 'DocSecurity', to: :doc_security
          map_element 'Lines', to: :lines
          map_element 'Paragraphs', to: :paragraphs
          map_element 'Bytes', to: :bytes
          map_element 'Category', to: :category
          map_element 'PresentationFormat', to: :presentation_format
          map_element 'Manager', to: :manager
          map_element 'Company', to: :company
          map_element 'Version', to: :version
        end
      end
    end
  end
end
