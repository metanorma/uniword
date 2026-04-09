# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Bibliography
    # Individual bibliography source entry with publication details
    #
    # Generated from OOXML schema: bibliography.yml
    # Element: <b:source>
    class Source < Lutaml::Model::Serializable
      attribute :source_type, :string
      attribute :tag, :string
      attribute :guid, :string
      attribute :lcid, :integer
      attribute :author, Author
      attribute :title, :string
      attribute :year, :string
      attribute :month, :string
      attribute :day, :string
      attribute :publisher, :string
      attribute :city, :string
      attribute :pages, :string
      attribute :volume, :string
      attribute :issue, :string
      attribute :edition, :string
      attribute :url, :string
      attribute :ref_order, :integer

      xml do
        element 'source'
        namespace Uniword::Ooxml::Namespaces::Bibliography
        mixed_content

        map_element 'SourceType', to: :source_type
        map_element 'Tag', to: :tag
        map_element 'GUID', to: :guid, render_nil: false
        map_element 'LCID', to: :lcid, render_nil: false
        map_element 'Author', to: :author, render_nil: false
        map_element 'Title', to: :title
        map_element 'Year', to: :year, render_nil: false
        map_element 'Month', to: :month, render_nil: false
        map_element 'Day', to: :day, render_nil: false
        map_element 'Publisher', to: :publisher, render_nil: false
        map_element 'City', to: :city, render_nil: false
        map_element 'Pages', to: :pages, render_nil: false
        map_element 'Volume', to: :volume, render_nil: false
        map_element 'Issue', to: :issue, render_nil: false
        map_element 'Edition', to: :edition, render_nil: false
        map_element 'URL', to: :url, render_nil: false
        map_element 'RefOrder', to: :ref_order, render_nil: false
      end
    end
  end
end
