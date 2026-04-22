# frozen_string_literal: true

require "thor"
require_relative "helpers"

module Uniword
  # Headers/Footers subcommand for Uniword CLI.
  #
  # Manages document headers and footers with support for
  # default, first-page, and even-page types.
  class HeadersCLI < Thor
    include CLIHelpers

    desc "list FILE", "List headers and footers"
    long_desc <<~DESC
      Display all headers and footers in a document.

      Examples:
        $ uniword headers list document.docx
        $ uniword headers list document.docx --json
    DESC
    option :json, desc: "Output as JSON", type: :boolean, default: false
    def list(path)
      doc = load_document(path)
      manager = HeadersFooters::Manager.new(doc)

      if options[:json]
        require "json"
        data = {
          headers: manager.list_headers,
          footers: manager.list_footers
        }
        puts JSON.pretty_generate(data)
        return
      end

      headers = manager.list_headers
      footers = manager.list_footers

      if headers.empty? && footers.empty?
        say "No headers or footers found.", :yellow
        return
      end

      unless headers.empty?
        say "Headers:", :cyan
        headers.each do |h|
          text = h[:empty] ? "(empty)" : truncate(h[:text])
          say "  [#{h[:type]}] #{text}"
        end
      end

      unless footers.empty?
        say "Footers:", :cyan
        footers.each do |f|
          text = f[:empty] ? "(empty)" : truncate(f[:text])
          say "  [#{f[:type]}] #{text}"
        end
      end
    rescue Uniword::Error => e
      handle_error(e)
    rescue StandardError => e
      handle_error(e)
    end

    desc "add-header FILE TEXT", "Add a header to the document"
    long_desc <<~DESC
      Add a header with the specified text.

      Examples:
        $ uniword headers add-header document.docx "Confidential" -o out.docx
        $ uniword headers add-header document.docx "Title" --type first -o out.docx
    DESC
    option :output, aliases: "-o", required: true, type: :string
    option :type, desc: "Header type (default/first/even)",
                  type: :string, default: "default"
    def add_header(path, text)
      doc = load_document(path)
      manager = HeadersFooters::Manager.new(doc)

      manager.add_header(text, type: options[:type])
      doc.save(options[:output])
      say "Added #{options[:type]} header to #{options[:output]}", :green
    rescue Uniword::Error => e
      handle_error(e)
    rescue StandardError => e
      handle_error(e)
    end

    desc "add-footer FILE TEXT", "Add a footer to the document"
    long_desc <<~DESC
      Add a footer with the specified text.

      Examples:
        $ uniword headers add-footer document.docx "Page 1" -o out.docx
    DESC
    option :output, aliases: "-o", required: true, type: :string
    option :type, desc: "Footer type (default/first/even)",
                  type: :string, default: "default"
    def add_footer(path, text)
      doc = load_document(path)
      manager = HeadersFooters::Manager.new(doc)

      manager.add_footer(text, type: options[:type])
      doc.save(options[:output])
      say "Added #{options[:type]} footer to #{options[:output]}", :green
    rescue Uniword::Error => e
      handle_error(e)
    rescue StandardError => e
      handle_error(e)
    end

    desc "remove FILE", "Remove headers or footers"
    long_desc <<~DESC
      Remove headers or footers by type.

      Examples:
        $ uniword headers remove document.docx --what headers --type default -o out.docx
        $ uniword headers remove document.docx --what all -o out.docx
    DESC
    option :output, aliases: "-o", required: true, type: :string
    option :what, desc: "What to remove (headers/footers/all)",
                  type: :string, default: "all"
    option :type, desc: "Type to remove (default/first/even)",
                  type: :string, default: "default"
    def remove(path)
      doc = load_document(path)
      manager = HeadersFooters::Manager.new(doc)

      case options[:what]
      when "headers"
        count = manager.remove_headers(type: options[:type])
        say "Removed #{count} header(s)", :green
      when "footers"
        count = manager.remove_footers(type: options[:type])
        say "Removed #{count} footer(s)", :green
      when "all"
        manager.clear_all
        say "Removed all headers and footers", :green
      else
        say "Invalid --what: #{options[:what]}. " \
            "Use headers, footers, or all.", :red
        exit 1
      end

      doc.save(options[:output])
    rescue Uniword::Error => e
      handle_error(e)
    rescue StandardError => e
      handle_error(e)
    end

    private

    def truncate(text, max_len = 60)
      text.length > max_len ? "#{text[0...max_len]}..." : text
    end
  end
end
