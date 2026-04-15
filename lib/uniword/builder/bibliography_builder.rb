# frozen_string_literal: true

module Uniword
  module Builder
    # Builds bibliography sources for a document.
    #
    # Manages the Bibliography::Sources collection, providing factory methods
    # for common source types (book, journal article, website, etc.).
    #
    # @example Create sources and attach to a document
    #   bib = BibliographyBuilder.new
    #   bib.book(tag: 'Smith2024', author: ['John Smith'],
    #            title: 'The Book', year: '2024', publisher: 'ACME')
    #   bib.journal(tag: 'Doe2023', author: ['Jane Doe'],
    #              title: 'The Paper', year: '2023',
    #              journal: 'Nature', volume: '42', pages: '1-10')
    #   bib.attach(document)
    #
    # @example Insert bibliography placeholder
    #   doc.paragraph { |p| p << SdtBuilder.bibliography.build }
    class BibliographyBuilder
      CHART_REL_TYPE =
        "http://schemas.openxmlformats.org/officeDocument/2006/relationships/bibliography"

      attr_reader :sources

      def initialize(style: "APA")
        @sources = Bibliography::Sources.new
        @sources.selected_style = style
        @ref_order_counter = 0
      end

      # Attach the bibliography sources to a document
      #
      # @param document [DocumentBuilder, DocumentRoot] Target document
      # @return [self]
      def attach(document)
        root = document.respond_to?(:model) ? document.model : document
        root.bibliography_sources = @sources
        self
      end

      # Create a book source
      #
      # @param tag [String] Unique tag identifier (e.g., 'Smith2024')
      # @param author [Array<String>] List of author names (format: 'First Last')
      # @param title [String] Book title
      # @param year [String] Publication year
      # @param publisher [String] Publisher name
      # @param city [String, nil] Publisher city
      # @param edition [String, nil] Edition
      # @return [self]
      def book(tag:, author:, title:, year:, publisher:,
               city: nil, edition: nil)
        src = build_source("Book", tag: tag, author: author,
                                   title: title, year: year,
                                   publisher: publisher, city: city,
                                   edition: edition)
        @sources.source << src
        self
      end

      # Create a journal article source
      #
      # @param tag [String] Unique tag identifier
      # @param author [Array<String>] List of author names
      # @param title [String] Article title
      # @param year [String] Publication year
      # @param journal [String] Journal name
      # @param volume [String, nil] Volume number
      # @param issue [String, nil] Issue number
      # @param pages [String, nil] Page range
      # @return [self]
      def journal(tag:, author:, title:, year:, journal:,
                  volume: nil, issue: nil, pages: nil)
        src = build_source("JournalArticle", tag: tag, author: author,
                                             title: title, year: year,
                                             publisher: journal, volume: volume,
                                             issue: issue, pages: pages)
        @sources.source << src
        self
      end

      # Create a website source
      #
      # @param tag [String] Unique tag identifier
      # @param author [Array<String>, nil] List of author names
      # @param title [String] Page title
      # @param year [String, nil] Publication/access year
      # @param url [String] URL
      # @return [self]
      def website(tag:, title:, url:, author: nil, year: nil)
        src = build_source("InternetSite", tag: tag, author: author,
                                           title: title, year: year, url: url)
        @sources.source << src
        self
      end

      # Create a conference proceedings source
      #
      # @param tag [String] Unique tag identifier
      # @param author [Array<String>] List of author names
      # @param title [String] Paper title
      # @param year [String] Publication year
      # @param publisher [String] Conference/organization name
      # @param city [String, nil] Conference location
      # @return [self]
      def conference(tag:, author:, title:, year:, publisher:,
                     city: nil)
        src = build_source("ConferenceProceedings", tag: tag,
                                                    author: author, title: title, year: year,
                                                    publisher: publisher, city: city)
        @sources.source << src
        self
      end

      # Create a generic/artistic source
      #
      # @param tag [String] Unique tag identifier
      # @param source_type [String] OOXML source type string
      # @param title [String] Title
      # @param author [Array<String>, nil] List of author names
      # @param year [String, nil] Year
      # @param kwargs [Hash] Additional fields (publisher, url, pages, etc.)
      # @return [self]
      def source(tag:, source_type:, title:, author: nil,
                 year: nil, **)
        src = build_source(source_type, tag: tag, author: author,
                                        title: title, year: year, **)
        @sources.source << src
        self
      end

      # Set the citation style
      #
      # @param style [String] Style name (e.g., 'APA', 'MLA', 'Chicago')
      # @return [self]
      def style=(style)
        @sources.selected_style = style
        self
      end

      # Build and return the Sources model
      #
      # @return [Bibliography::Sources]
      def build
        @sources
      end

      private

      # Build a Bibliography::Source from common parameters
      def build_source(type, tag:, author: nil, title: nil, year: nil,
                       publisher: nil, city: nil, volume: nil,
                       issue: nil, pages: nil, edition: nil, url: nil)
        @ref_order_counter += 1

        src = Bibliography::Source.new
        src.source_type = type
        src.tag = tag
        src.ref_order = @ref_order_counter
        src.title = title if title
        src.year = year if year
        src.publisher = publisher if publisher
        src.city = city if city
        src.volume = volume if volume
        src.issue = issue if issue
        src.pages = pages if pages
        src.edition = edition if edition
        src.url = url if url

        if author && !author.empty?
          src.author = Bibliography::Author.new
          src.author.name_list = Bibliography::NameList.new
          author.each do |name|
            parts = name.to_s.split(" ", 2)
            person = Bibliography::Person.new
            person.first = parts[0] if parts[0]
            person.last = parts[1] if parts[1]
            src.author.name_list.person << person
          end
        end

        src
      end
    end
  end
end
