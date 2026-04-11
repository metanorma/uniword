# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Bibliography
    # Individual bibliography source entry with publication details
    #
    # XSD: CT_SourceType - contains all citation metadata fields.
    # Element: <b:Source>
    class Source < Lutaml::Model::Serializable
      # Core identification
      attribute :source_type, :string
      attribute :tag, :string
      attribute :guid, :string
      attribute :lcid, :string

      # Author/contributor (CT_AuthorType - complex nested structure)
      attribute :author, Author

      # Title fields
      attribute :title, :string
      attribute :short_title, :string
      attribute :book_title, :string
      attribute :album_title, :string
      attribute :periodical_title, :string
      attribute :publication_title, :string
      attribute :internet_site_title, :string
      attribute :broadcast_title, :string
      attribute :conference_name, :string

      # Date fields
      attribute :year, :string
      attribute :month, :string
      attribute :day, :string
      attribute :year_accessed, :string
      attribute :month_accessed, :string
      attribute :day_accessed, :string

      # Publication details
      attribute :publisher, :string
      attribute :city, :string
      attribute :state_province, :string
      attribute :country_region, :string
      attribute :pages, :string
      attribute :volume, :string
      attribute :number_volumes, :string
      attribute :issue, :string
      attribute :edition, :string
      attribute :journal_name, :string
      attribute :standard_number, :string
      attribute :chapter_number, :string

      # Legal/court fields
      attribute :case_number, :string
      attribute :abbreviated_case_number, :string
      attribute :court, :string
      attribute :reporter, :string

      # Media/broadcast fields
      attribute :broadcaster, :string
      attribute :station, :string
      attribute :theater, :string
      attribute :distributor, :string
      attribute :production_company, :string
      attribute :medium, :string
      attribute :patent_number, :string
      attribute :recording_number, :string

      # Academic/institutional fields
      attribute :institution, :string
      attribute :department, :string
      attribute :thesis_type, :string
      attribute :degree, :string

      # Digital/online
      attribute :url, :string

      # Descriptive
      attribute :comments, :string
      attribute :source_version, :string
      attribute :source_kind, :string

      # Ordering
      attribute :ref_order, :string

      xml do
        element 'Source'
        namespace Uniword::Ooxml::Namespaces::Bibliography
        mixed_content

        # Core identification
        map_element 'SourceType', to: :source_type, render_nil: false
        map_element 'Tag', to: :tag, render_nil: false
        map_element 'Guid', to: :guid, render_nil: false
        map_element 'LCID', to: :lcid, render_nil: false

        # Author (CT_AuthorType)
        map_element 'Author', to: :author, render_nil: false

        # Title fields
        map_element 'Title', to: :title, render_nil: false
        map_element 'ShortTitle', to: :short_title, render_nil: false
        map_element 'BookTitle', to: :book_title, render_nil: false
        map_element 'AlbumTitle', to: :album_title, render_nil: false
        map_element 'PeriodicalTitle', to: :periodical_title, render_nil: false
        map_element 'PublicationTitle', to: :publication_title, render_nil: false
        map_element 'InternetSiteTitle', to: :internet_site_title, render_nil: false
        map_element 'BroadcastTitle', to: :broadcast_title, render_nil: false
        map_element 'ConferenceName', to: :conference_name, render_nil: false

        # Date fields
        map_element 'Year', to: :year, render_nil: false
        map_element 'Month', to: :month, render_nil: false
        map_element 'Day', to: :day, render_nil: false
        map_element 'YearAccessed', to: :year_accessed, render_nil: false
        map_element 'MonthAccessed', to: :month_accessed, render_nil: false
        map_element 'DayAccessed', to: :day_accessed, render_nil: false

        # Publication details
        map_element 'Publisher', to: :publisher, render_nil: false
        map_element 'City', to: :city, render_nil: false
        map_element 'StateProvince', to: :state_province, render_nil: false
        map_element 'CountryRegion', to: :country_region, render_nil: false
        map_element 'Pages', to: :pages, render_nil: false
        map_element 'Volume', to: :volume, render_nil: false
        map_element 'NumberVolumes', to: :number_volumes, render_nil: false
        map_element 'Issue', to: :issue, render_nil: false
        map_element 'Edition', to: :edition, render_nil: false
        map_element 'JournalName', to: :journal_name, render_nil: false
        map_element 'StandardNumber', to: :standard_number, render_nil: false
        map_element 'ChapterNumber', to: :chapter_number, render_nil: false

        # Legal/court fields
        map_element 'CaseNumber', to: :case_number, render_nil: false
        map_element 'AbbreviatedCaseNumber', to: :abbreviated_case_number, render_nil: false
        map_element 'Court', to: :court, render_nil: false
        map_element 'Reporter', to: :reporter, render_nil: false

        # Media/broadcast fields
        map_element 'Broadcaster', to: :broadcaster, render_nil: false
        map_element 'Station', to: :station, render_nil: false
        map_element 'Theater', to: :theater, render_nil: false
        map_element 'Distributor', to: :distributor, render_nil: false
        map_element 'ProductionCompany', to: :production_company, render_nil: false
        map_element 'Medium', to: :medium, render_nil: false
        map_element 'PatentNumber', to: :patent_number, render_nil: false
        map_element 'RecordingNumber', to: :recording_number, render_nil: false

        # Academic/institutional fields
        map_element 'Institution', to: :institution, render_nil: false
        map_element 'Department', to: :department, render_nil: false
        map_element 'ThesisType', to: :thesis_type, render_nil: false
        map_element 'Degree', to: :degree, render_nil: false

        # Digital/online
        map_element 'URL', to: :url, render_nil: false

        # Descriptive
        map_element 'Comments', to: :comments, render_nil: false
        map_element 'Version', to: :source_version, render_nil: false
        map_element 'Type', to: :source_kind, render_nil: false

        # Ordering
        map_element 'RefOrder', to: :ref_order, render_nil: false
      end
    end
  end
end
