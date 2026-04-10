# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Assembly
    # Table of Contents field instruction.
    #
    # Represents the TOC field code that Word uses to generate and update TOC.
    # Example field code: { TOC \o "1-3" \h \z \u }
    #
    # @example Create TOC instruction
    #   instr = TocInstruction.new(
    #     outline_levels: "1-3",
    #     hyperlinks: true,
    #     hidden_formats: true,
    #     use_paragraph_outline: true
    #   )
    class TocInstruction < Lutaml::Model::Serializable
      # @return [String, nil] Outline levels to include (e.g., "1-3")
      attribute :outline_levels, :string

      # @return [Boolean] Include hyperlinks in TOC
      attribute :hyperlinks, :boolean, default: -> { true }

      # @return [Boolean] Use hidden formats
      attribute :hidden_formats, :boolean, default: -> { true }

      # @return [Boolean] Use paragraph outline level
      attribute :use_paragraph_outline, :boolean, default: -> { true }

      # @return [Boolean] Preserve tab stops
      attribute :preserve_tabs, :boolean, default: -> { false }

      # @return [String, nil] Custom separator
      attribute :separator, :string

      # @return [String, nil] Custom leader
      attribute :leader, :string

      # Generate the field instruction string.
      #
      # @return [String] The TOC field instruction
      #
      # @example
      #   instr.to_s # => "TOC \\o \"1-3\" \\h \\z \\u"
      def to_s
        parts = ['TOC']

        parts << "\\o \"#{outline_levels}\"" if outline_levels
        parts << '\\h' if hyperlinks
        parts << '\\z' if hidden_formats
        parts << '\\u' if use_paragraph_outline
        parts << '\\w' if preserve_tabs
        parts << "\\s \"#{separator}\"" if separator
        parts << "\\l \"#{leader}\"" if leader

        parts.join(' ')
      end

      # Parse a TOC field instruction string.
      #
      # @param str [String] The field instruction string
      # @return [TocInstruction] Parsed instruction
      #
      # @example
      #   TocInstruction.parse('TOC \\o "1-3" \\h \\z')
      def self.parse(str)
        return nil if str.nil? || str.strip.empty?

        instr = new

        # Parse outline levels: \o "1-3"
        instr.outline_levels = ::Regexp.last_match(1) if str =~ /\\o\s+"([^"]+)"/

        # Parse switches
        instr.hyperlinks = str.include?('\\h')
        instr.hidden_formats = str.include?('\\z')
        instr.use_paragraph_outline = str.include?('\\u')
        instr.preserve_tabs = str.include?('\\w')

        # Parse separator: \s "separator"
        instr.separator = ::Regexp.last_match(1) if str =~ /\\s\s+"([^"]+)"/

        # Parse leader: \l "leader"
        instr.leader = ::Regexp.last_match(1) if str =~ /\\l\s+"([^"]+)"/

        instr
      end
    end
  end
end
