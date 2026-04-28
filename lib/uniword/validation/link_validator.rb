# frozen_string_literal: true

# All classes autoloaded via lib/uniword/validation.rb and lib/uniword/configuration.rb

module Uniword
  module Validation
    # Main orchestrator for link validation.
    #
    # Responsibility: Coordinate link validation across entire document.
    # Single Responsibility: Link validation orchestration only.
    #
    # The LinkValidator:
    # - Loads configuration from external YAML
    # - Initializes appropriate checkers
    # - Finds all links in document
    # - Routes each link to appropriate checker
    # - Aggregates results into ValidationReport
    #
    # Follows Open/Closed principle:
    # - Adding new checker types requires no changes to this class
    # - Checkers are configured externally
    #
    # @example Basic usage
    #   validator = LinkValidator.new
    #   report = validator.validate(document)
    #   puts "Valid: #{report.valid?}"
    #   report.export_html('report.html')
    #
    # @example Custom configuration
    #   validator = LinkValidator.new(
    #     config_file: 'custom_validation_rules.yml'
    #   )
    #   report = validator.validate(document)
    class LinkValidator
      # @return [Hash] Loaded configuration
      attr_reader :config

      # @return [Array<LinkChecker>] Registered checkers
      attr_reader :checkers

      # Initialize a new LinkValidator.
      #
      # @param config_file [String] Path to configuration file
      #
      # @example Create validator
      #   validator = LinkValidator.new
      #
      # @example Custom config file
      #   validator = LinkValidator.new(
      #     config_file: 'config/custom_rules.yml'
      #   )
      def initialize(config_file: "link_validation_rules")
        @config = load_configuration(config_file)
        @checkers = initialize_checkers
      end

      # Validate all links in a document.
      #
      # @param document [Object] The document to validate
      # @return [ValidationReport] Validation report with all results
      #
      # @example Validate document
      #   report = validator.validate(document)
      #   puts "Found #{report.total_count} links"
      #   puts "Failures: #{report.failure_count}"
      def validate(document)
        report = ValidationReport.new

        # Validate hyperlinks
        validate_hyperlinks(document, report)

        # Validate bookmarks (cross-references)
        validate_bookmarks(document, report)

        # Validate footnote references
        validate_footnotes(document, report)

        report
      end

      private

      # Load configuration from file.
      #
      # @param config_file [String] Configuration file name or path
      # @return [Hash] Loaded configuration
      def load_configuration(config_file)
        if File.exist?(config_file)
          Configuration::ConfigurationLoader.load_file(config_file)
        else
          Configuration::ConfigurationLoader.load(config_file)
        end
      rescue Configuration::ConfigurationError => e
        # Use defaults if config file not found
        warn "Warning: #{e.message}. Using default configuration."
        { link_validation: default_configuration }
      end

      # Get default configuration.
      #
      # @return [Hash] Default configuration
      def default_configuration
        {
          external_links: { enabled: true },
          internal_bookmarks: { enabled: true },
          file_references: { enabled: true },
          footnote_references: { enabled: true },
        }
      end

      # Initialize all link checkers from configuration.
      #
      # @return [Array<LinkChecker>] Array of checker instances
      def initialize_checkers
        config_root = @config[:link_validation] || @config

        [
          Checkers::ExternalLinkChecker.new(
            config: config_root[:external_links] || {},
          ),
          Checkers::InternalLinkChecker.new(
            config: config_root[:internal_bookmarks] || {},
          ),
          Checkers::FileReferenceChecker.new(
            config: config_root[:file_references] || {},
          ),
          Checkers::FootnoteReferenceChecker.new(
            config: config_root[:footnote_references] || {},
          ),
        ]
      end

      # Validate hyperlinks in document.
      #
      # @param document [Object] The document
      # @param report [ValidationReport] Report to add results to
      def validate_hyperlinks(document, report)
        links = extract_hyperlinks(document)

        links.each do |link|
          result = check_link(link, document)
          report.add_result(result)
        end
      end

      # Validate bookmark references in document.
      #
      # @param document [Object] The document
      # @param report [ValidationReport] Report to add results to
      def validate_bookmarks(document, report)
        # Bookmark validation is handled through hyperlinks
        # with anchor attributes, so this is already covered
        # by validate_hyperlinks
      end

      # Validate footnote references in document.
      #
      # @param document [Object] The document
      # @param report [ValidationReport] Report to add results to
      def validate_footnotes(document, report)
        footnote_refs = extract_footnote_references(document)

        footnote_refs.each do |ref|
          result = check_link(ref, document)
          report.add_result(result)
        end
      end

      # Check a single link using appropriate checker.
      #
      # @param link [Object] The link to check
      # @param document [Object] The document (for context)
      # @return [ValidationResult] Validation result
      def check_link(link, document)
        # Find appropriate checker
        checker = @checkers.find { |c| c.can_check?(link) }

        if checker
          checker.check(link, document)
        else
          ValidationResult.unknown(
            link,
            "No checker available for this link type",
          )
        end
      end

      # Extract hyperlinks from document.
      #
      # @param document [Object] The document
      # @return [Array] Array of hyperlinks
      def extract_hyperlinks(document)
        links = []

        # Extract from paragraphs
        if document.respond_to?(:paragraphs)
          document.paragraphs.each do |para|
            links.concat(extract_links_from_paragraph(para))
          end
        end

        # Extract from tables
        if document.respond_to?(:tables)
          document.tables.each do |table|
            links.concat(extract_links_from_table(table))
          end
        end

        # Extract from headers/footers
        if document.respond_to?(:headers) && document.headers
          document.headers.each do |header|
            links.concat(extract_links_from_section(header))
          end
        end

        if document.respond_to?(:footers) && document.footers
          document.footers.each do |footer|
            links.concat(extract_links_from_section(footer))
          end
        end

        links.uniq
      end

      # Extract links from paragraph.
      #
      # @param paragraph [Object] The paragraph
      # @return [Array] Array of links
      def extract_links_from_paragraph(para)
        links = []

        # Check paragraph runs for hyperlinks
        if para.respond_to?(:runs)
          para.runs.each do |run|
            links << run if run.is_a?(Wordprocessingml::Hyperlink)
          end
        end

        # Check for hyperlinks collection
        links.concat(para.hyperlinks) if para.respond_to?(:hyperlinks)

        links
      end

      # Extract links from table.
      #
      # @param table [Object] The table
      # @return [Array] Array of links
      def extract_links_from_table(table)
        links = []

        if table.respond_to?(:rows)
          table.rows.each do |row|
            next unless row.respond_to?(:cells)

            row.cells.each do |cell|
              next unless cell.respond_to?(:paragraphs)

              cell.paragraphs.each do |para|
                links.concat(extract_links_from_paragraph(para))
              end
            end
          end
        end

        links
      end

      # Extract links from document section (header/footer).
      #
      # @param section [Object] The section
      # @return [Array] Array of links
      def extract_links_from_section(section)
        links = []

        if section.respond_to?(:paragraphs)
          section.paragraphs.each do |para|
            links.concat(extract_links_from_paragraph(para))
          end
        end

        links
      end

      # Extract footnote references from document.
      #
      # @param document [Object] The document
      # @return [Array] Array of footnote references
      def extract_footnote_references(document)
        refs = []

        # Check if document has footnotes
        if document.respond_to?(:footnotes)
          footnotes = document.footnotes
          case footnotes
          when Hash
            refs.concat(footnotes.values)
          when Array
            refs.concat(footnotes)
          end
        end

        # Check if document has endnotes
        if document.respond_to?(:endnotes)
          endnotes = document.endnotes
          case endnotes
          when Hash
            refs.concat(endnotes.values)
          when Array
            refs.concat(endnotes)
          end
        end

        refs
      end
    end
  end
end
