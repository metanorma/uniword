# frozen_string_literal: true

require "thor"

module Uniword
  # Shared error handling for all CLI classes.
  #
  # Included by every Thor subcommand class to provide consistent
  # error handling and common document-loading helpers.
  module CLIHelpers
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def exit_on_failure?
        true
      end
    end

    private

    def load_document(path)
      unless File.exist?(path)
        say("File not found: #{path}", :red)
        exit 1
      end

      DocumentFactory.from_file(path)
    end

    def handle_error(error, verbose: false)
      case error
      when Uniword::Error
        say("Error: #{error.message}", :red)
      else
        say("Unexpected error: #{error.message}", :red)
        say(error.backtrace.join("\n"), :red) if verbose
      end
      exit 1
    end
  end
end
