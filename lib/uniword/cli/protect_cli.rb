# frozen_string_literal: true

require "thor"
require_relative "helpers"

module Uniword
  # Protect subcommand for Uniword CLI.
  #
  # Manages document editing restrictions and password protection.
  class ProtectCLI < Thor
    include CLIHelpers

    desc "apply FILE", "Apply editing restriction"
    long_desc <<~DESC
      Apply editing restriction to a document.

      Protection types:
        - read_only: No edits allowed
        - comments: Only comments allowed
        - tracked_changes: Only tracked changes allowed
        - forms: Only form fields editable

      Examples:
        $ uniword protect apply document.docx --type read_only -o out.docx
        $ uniword protect apply document.docx --type comments --password secret -o out.docx
    DESC
    option :output, aliases: "-o", required: true, type: :string
    option :type, desc: "Protection type", type: :string,
                  default: "read_only"
    option :password, desc: "Optional password", type: :string
    def apply(path)
      doc = load_document(path)
      manager = Protect::Manager.new(doc)

      protection_type = options[:type].to_sym
      manager.apply(protection_type, password: options[:password])

      doc.save(options[:output])
      say "Applied #{options[:type]} protection to #{options[:output]}",
          :green
      say "Password protected" if options[:password]
    rescue ArgumentError => e
      say "Error: #{e.message}", :red
      exit 1
    rescue Uniword::Error => e
      handle_error(e)
    rescue StandardError => e
      handle_error(e)
    end

    desc "remove FILE", "Remove document protection"
    long_desc <<~DESC
      Remove all editing restrictions from a document.

      Examples:
        $ uniword protect remove document.docx -o unprotected.docx
    DESC
    option :output, aliases: "-o", required: true, type: :string
    def remove(path)
      doc = load_document(path)
      manager = Protect::Manager.new(doc)

      manager.remove
      doc.save(options[:output])
      say "Removed protection from #{options[:output]}", :green
    rescue Uniword::Error => e
      handle_error(e)
    rescue StandardError => e
      handle_error(e)
    end

    desc "info FILE", "Show document protection status"
    long_desc <<~DESC
      Display the current protection status of a document.

      Examples:
        $ uniword protect info document.docx
    DESC
    def info(path)
      doc = load_document(path)
      manager = Protect::Manager.new(doc)

      if manager.protected?
        details = manager.info
        say "Document is protected:", :yellow
        say "  Type: #{details[:type]}"
        say "  Password: #{details[:password_protected] ? 'Yes' : 'No'}"
      else
        say "Document is not protected.", :green
      end
    rescue Uniword::Error => e
      handle_error(e)
    rescue StandardError => e
      handle_error(e)
    end
  end
end
