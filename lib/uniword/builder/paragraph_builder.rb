# frozen_string_literal: true

require "digest"

module Uniword
  module Builder
    class ParagraphBuilder < BaseBuilder
      include HasBorders
      include HasShading

      @sequence = 0
      @mutex = Mutex.new

      class << self
        attr_accessor :sequence, :mutex
      end

      def self.default_model_class
        Wordprocessingml::Paragraph
      end

      attr_reader :allocator

      def initialize(model = nil, allocator: nil)
        @allocator = allocator
        super(model)
        assign_tracking_attributes
      end

      # Append a child element. Routes by type:
      # - String -> creates a Run
      # - Run -> appends to runs
      # - Hyperlink -> appends to hyperlinks
      # - TabStop -> appends to properties.tabs
      # - BookmarkStart/End -> appends to bookmarks
      # - StructuredDocumentTag -> appends to sdts
      #
      # @param element [String, Run, Hyperlink, Properties::TabStop, ...]
      # @return [self]
      def <<(element)
        case element
        when String
          append_string(element)
        when Wordprocessingml::Run
          append_run(element)
        when Wordprocessingml::Hyperlink
          @model.hyperlinks << element
          track_element_order("hyperlink")
        when Properties::TabStop
          ensure_properties
          @model.properties.tabs ||= Properties::Tabs.new
          @model.properties.tabs << element
        when Wordprocessingml::BookmarkStart
          @model.bookmark_starts << element
          track_element_order("bookmarkStart")
        when Wordprocessingml::BookmarkEnd
          @model.bookmark_ends << element
          track_element_order("bookmarkEnd")
        when Wordprocessingml::StructuredDocumentTag
          @model.sdts << element
          track_element_order("sdt")
        when Wordprocessingml::SimpleField
          @model.simple_fields << element
          track_element_order("fldSimple")
        when Math::OMath
          @model.o_maths << element
          track_element_order("oMath")
        when RunBuilder
          append_run(element.build)
        else
          raise ArgumentError, "Cannot add #{element.class} to paragraph"
        end
        self
      end

      def style=(name)
        ensure_properties.style = name
        self
      end

      def style
        @model.style
      end

      def align=(value)
        ensure_properties.alignment = Properties::Alignment.new(value: value.to_s)
        self
      end

      # Set paragraph spacing
      #
      # @param before [Integer, nil] Spacing before in twips
      # @param after [Integer, nil] Spacing after in twips
      # @param line [Integer, nil] Line spacing in twips
      # @param rule [String, nil] Line rule ('auto', 'exact', 'atLeast')
      # @return [self]
      def spacing(before: nil, after: nil, line: nil, rule: nil)
        ensure_properties.spacing ||= Properties::Spacing.new
        props = @model.properties.spacing
        props.before = before if before
        props.after = after if after
        props.line = line if line
        props.line_rule = rule if rule
        self
      end

      # Set paragraph indentation
      #
      # @param left [Integer, nil] Left indent in twips
      # @param right [Integer, nil] Right indent in twips
      # @param first_line [Integer, nil] First line indent in twips
      # @param hanging [Integer, nil] Hanging indent in twips
      # @return [self]
      def indent(left: nil, right: nil, first_line: nil, hanging: nil)
        ensure_properties.indentation ||= Properties::Indentation.new
        ind = @model.properties.indentation
        ind.left = left if left
        ind.right = right if right
        ind.first_line = first_line if first_line
        ind.hanging = hanging if hanging
        self
      end

      # Set numbering
      #
      # @param num_id [Integer] Numbering definition ID
      # @param level [Integer] Numbering level (0-based, default 0)
      # @return [self]
      def numbering(num_id, level = 0)
        props = ensure_properties
        props.num_id = num_id
        props.ilvl = level
        props.numbering_properties = Properties::NumberingProperties.new(
          num_id: Properties::NumberingId.new(value: num_id),
          ilvl: Properties::NumberingLevel.new(value: level),
        )
        self
      end

      def keep_next(value = true)
        ensure_properties.keep_next_wrapper =
          value ? Properties::KeepNext.new(value: true) : nil
        self
      end

      def page_break_before(value = true)
        ensure_properties.page_break_before_wrapper =
          value ? Properties::PageBreakBefore.new(value: true) : nil
        self
      end

      def contextual_spacing=(value)
        ensure_properties.contextual_spacing = value
        self
      end

      def outline_level=(value)
        ensure_properties.outline_level = value
        self
      end

      private

      def assign_tracking_attributes
        if @allocator
          @model.rsid_r = @allocator.alloc_rsid
          @model.para_id = Wordprocessingml::W14ParaId.new(@allocator.alloc_para_id)
        else
          idx = self.class.mutex.synchronize do
            self.class.sequence += 1
          end
          hash = Digest::SHA256.hexdigest("para:#{idx}:#{Process.pid}")
          @model.rsid_r = hash[0, 8]
          @model.para_id = Wordprocessingml::W14ParaId.new(hash[8, 8])
        end
        @model.rsid_r_default = "00000000"
        @model.text_id = Wordprocessingml::W14TextId.new("77777777")
      end

      def append_run(run)
        return if RunUtils.empty_run?(run)

        last = @model.runs.last
        if last && RunUtils.mergeable?(last, run)
          RunUtils.merge_text(last, run)
        else
          @model.runs << run
          track_element_order("r")
        end
      end

      def append_string(str)
        return if str.nil? || str.empty?

        unless str.include?("\n")
          @model.runs << Wordprocessingml::Run.new(text: str)
          track_element_order("r")
          return
        end

        segments = str.split("\n", -1)
        segments.each_with_index do |seg, i|
          unless seg.empty?
            @model.runs << Wordprocessingml::Run.new(text: seg)
            track_element_order("r")
          end
          if i < segments.size - 1
            br_run = Wordprocessingml::Run.new
            br_run.break = Wordprocessingml::Break.new
            @model.runs << br_run
            track_element_order("r")
          end
        end
      end

      def properties_tag
        "pPr"
      end

      def ensure_properties
        @model.properties ||= Wordprocessingml::ParagraphProperties.new
        ensure_properties_in_order
        @model.properties
      end
    end
  end
end
