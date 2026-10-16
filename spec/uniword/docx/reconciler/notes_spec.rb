# frozen_string_literal: true

require "spec_helper"
require "uniword/docx"

RSpec.describe Uniword::Docx::Reconciler do
  let(:settings_class) { Uniword::Wordprocessingml::Settings }
  let(:footnotes_class) { Uniword::Wordprocessingml::Footnotes }
  let(:endnotes_class) { Uniword::Wordprocessingml::Endnotes }
  let(:footnote_class) { Uniword::Wordprocessingml::Footnote }
  let(:endnote_class) { Uniword::Wordprocessingml::Endnote }
  let(:footnote_pr_class) { Uniword::Wordprocessingml::FootnotePr }
  let(:endnote_pr_class) { Uniword::Wordprocessingml::EndnotePr }
  let(:para_class) { Uniword::Wordprocessingml::Paragraph }

  def build_package(settings: nil, footnotes: nil, endnotes: nil)
    package = Uniword::Docx::Package.new
    package.settings = settings
    package.footnotes = footnotes
    package.endnotes = endnotes
    package
  end

  describe "footnotes reconciliation" do
    it "creates minimal footnotes when footnote_pr is set but footnotes is nil" do
      settings = settings_class.new
      settings.footnote_pr = footnote_pr_class.new
      package = build_package(settings: settings, footnotes: nil, endnotes: nil)

      described_class.new(package).reconcile

      expect(package.footnotes).to be_a(footnotes_class)
      expect(package.footnotes.footnote_entries.size).to eq(2)
    end

    it "creates separator footnotes with proper paragraph spacing" do
      settings = settings_class.new
      settings.footnote_pr = footnote_pr_class.new
      package = build_package(settings: settings, footnotes: nil, endnotes: nil)

      described_class.new(package).reconcile

      sep = package.footnotes.footnote_entries.find { |e| e.id == "-1" }
      para = sep.paragraphs.first
      expect(para).not_to be_nil
      expect(para.properties).not_to be_nil
      spacing = para.properties.spacing
      expect(spacing).not_to be_nil
      expect(spacing.after).to eq(0)
      expect(spacing.line).to eq(240)
      expect(spacing.line_rule).to eq("auto")
    end

    it "creates footnote_pr when footnotes exist but footnote_pr is nil" do
      settings = settings_class.new
      footnotes = footnotes_class.new(
        footnote_entries: [
          footnote_class.new(id: "1", paragraphs: []),
        ],
      )
      package = build_package(settings: settings, footnotes: footnotes,
                              endnotes: nil)

      described_class.new(package).reconcile

      expect(settings.footnote_pr).to be_a(footnote_pr_class)
    end

    it "does not change when both footnote_pr and footnotes are set" do
      settings = settings_class.new
      settings.footnote_pr = footnote_pr_class.new
      original_footnotes = footnotes_class.new(
        footnote_entries: [
          footnote_class.new(id: "-1", type: "separator", paragraphs: []),
          footnote_class.new(id: "0", type: "continuationSeparator",
                             paragraphs: []),
          footnote_class.new(id: "1", paragraphs: []),
        ],
      )
      package = build_package(settings: settings,
                              footnotes: original_footnotes, endnotes: nil)

      described_class.new(package).reconcile

      expect(package.footnotes).to equal(original_footnotes)
      expect(settings.footnote_pr).to be_a(footnote_pr_class)
    end

    it "does not change when neither footnote_pr nor footnotes are set" do
      settings = settings_class.new
      package = build_package(settings: settings, footnotes: nil, endnotes: nil)

      described_class.new(package).reconcile

      expect(package.footnotes).to be_nil
    end

    it "strips invalid w:type from normal footnotes" do
      settings = settings_class.new
      settings.footnote_pr = footnote_pr_class.new
      footnotes = footnotes_class.new(
        footnote_entries: [
          footnote_class.new(id: "-1", type: "separator", paragraphs: []),
          footnote_class.new(id: "0", type: "continuationSeparator", paragraphs: []),
          footnote_class.new(id: "1", type: "normal", paragraphs: []),
        ],
      )
      package = build_package(settings: settings, footnotes: footnotes)

      described_class.new(package).reconcile

      fn1 = footnotes.footnote_entries.find { |e| e.id == "1" }
      expect(fn1.type).to be_nil
    end

    it "preserves valid separator types" do
      settings = settings_class.new
      settings.footnote_pr = footnote_pr_class.new
      footnotes = footnotes_class.new(
        footnote_entries: [
          footnote_class.new(id: "-1", type: "separator", paragraphs: []),
          footnote_class.new(id: "0", type: "continuationSeparator", paragraphs: []),
        ],
      )
      package = build_package(settings: settings, footnotes: footnotes)

      described_class.new(package).reconcile

      sep = footnotes.footnote_entries.find { |e| e.id == "-1" }
      cont = footnotes.footnote_entries.find { |e| e.id == "0" }
      expect(sep.type).to eq("separator")
      expect(cont.type).to eq("continuationSeparator")
    end

    it "injects missing separator entry (id=-1)" do
      settings = settings_class.new
      settings.footnote_pr = footnote_pr_class.new
      footnotes = footnotes_class.new(
        footnote_entries: [
          footnote_class.new(id: "0", type: "continuationSeparator",
                             paragraphs: []),
          footnote_class.new(id: "1", paragraphs: []),
        ],
      )
      package = build_package(settings: settings, footnotes: footnotes,
                              endnotes: nil)

      described_class.new(package).reconcile

      ids = footnotes.footnote_entries.map(&:id)
      expect(ids).to include("-1")
    end

    it "injects missing continuation entry (id=0)" do
      settings = settings_class.new
      settings.footnote_pr = footnote_pr_class.new
      footnotes = footnotes_class.new(
        footnote_entries: [
          footnote_class.new(id: "-1", type: "separator", paragraphs: []),
          footnote_class.new(id: "1", paragraphs: []),
        ],
      )
      package = build_package(settings: settings, footnotes: footnotes,
                              endnotes: nil)

      described_class.new(package).reconcile

      ids = footnotes.footnote_entries.map(&:id)
      expect(ids).to include("0")
    end
  end

  describe "endnotes reconciliation" do
    it "creates minimal endnotes when endnote_pr is set but endnotes is nil" do
      settings = settings_class.new
      settings.endnote_pr = endnote_pr_class.new
      package = build_package(settings: settings, footnotes: nil, endnotes: nil)

      described_class.new(package).reconcile

      expect(package.endnotes).to be_a(endnotes_class)
      expect(package.endnotes.endnote_entries.size).to eq(2)
    end

    it "creates endnote_pr when endnotes exist but endnote_pr is nil" do
      settings = settings_class.new
      endnotes = endnotes_class.new(
        endnote_entries: [
          endnote_class.new(id: "1", paragraphs: []),
        ],
      )
      package = build_package(settings: settings, footnotes: nil,
                              endnotes: endnotes)

      described_class.new(package).reconcile

      expect(settings.endnote_pr).to be_a(endnote_pr_class)
    end

    it "does not change when both endnote_pr and endnotes are set" do
      settings = settings_class.new
      settings.endnote_pr = endnote_pr_class.new
      original_endnotes = endnotes_class.new(
        endnote_entries: [
          endnote_class.new(id: "-1", type: "separator", paragraphs: []),
          endnote_class.new(id: "0", type: "continuationSeparator",
                            paragraphs: []),
          endnote_class.new(id: "1", paragraphs: []),
        ],
      )
      package = build_package(settings: settings, footnotes: nil,
                              endnotes: original_endnotes)

      described_class.new(package).reconcile

      expect(package.endnotes).to equal(original_endnotes)
      expect(settings.endnote_pr).to be_a(endnote_pr_class)
    end

    it "does not change when neither endnote_pr nor endnotes are set" do
      settings = settings_class.new
      package = build_package(settings: settings, footnotes: nil, endnotes: nil)

      described_class.new(package).reconcile

      expect(package.endnotes).to be_nil
    end

    it "injects missing separator entry (id=-1)" do
      settings = settings_class.new
      settings.endnote_pr = endnote_pr_class.new
      endnotes = endnotes_class.new(
        endnote_entries: [
          endnote_class.new(id: "0", type: "continuationSeparator",
                            paragraphs: []),
          endnote_class.new(id: "1", paragraphs: []),
        ],
      )
      package = build_package(settings: settings, footnotes: nil,
                              endnotes: endnotes)

      described_class.new(package).reconcile

      ids = endnotes.endnote_entries.map(&:id)
      expect(ids).to include("-1")
    end

    it "injects missing continuation entry (id=0)" do
      settings = settings_class.new
      settings.endnote_pr = endnote_pr_class.new
      endnotes = endnotes_class.new(
        endnote_entries: [
          endnote_class.new(id: "-1", type: "separator", paragraphs: []),
          endnote_class.new(id: "1", paragraphs: []),
        ],
      )
      package = build_package(settings: settings, footnotes: nil,
                              endnotes: endnotes)

      described_class.new(package).reconcile

      ids = endnotes.endnote_entries.map(&:id)
      expect(ids).to include("0")
    end
  end

  describe "note reference validation (R10)" do
    let(:run_class) { Uniword::Wordprocessingml::Run }
    let(:fn_ref_class) { Uniword::Wordprocessingml::FootnoteReference }
    let(:en_ref_class) { Uniword::Wordprocessingml::EndnoteReference }
    let(:table_class) { Uniword::Wordprocessingml::Table }
    let(:row_class) { Uniword::Wordprocessingml::TableRow }
    let(:cell_class) { Uniword::Wordprocessingml::TableCell }
    let(:body_class) { Uniword::Wordprocessingml::Body }

    def build_package_with_refs(ref_ids_in_tables: [], ref_ids_in_paras: [])
      document = Uniword::Wordprocessingml::DocumentRoot.new

      paras = ref_ids_in_paras.map do |id|
        para_class.new(runs: [run_class.new(footnote_reference: fn_ref_class.new(id: id))])
      end

      if ref_ids_in_tables.any?
        cells = ref_ids_in_tables.map do |id|
          cell_class.new(
            paragraphs: [para_class.new(
              runs: [run_class.new(footnote_reference: fn_ref_class.new(id: id))]
            )]
          )
        end
        tbl = table_class.new(rows: [row_class.new(cells: cells)])
        document.body = body_class.new(paragraphs: paras, tables: [tbl])
      else
        document.body = body_class.new(paragraphs: paras)
      end

      package = Uniword::Docx::Package.new
      package.document = document
      package
    end

    it "finds footnote references in table cells" do
      footnotes = footnotes_class.new(
        footnote_entries: [
          footnote_class.new(id: "-1", type: "separator", paragraphs: []),
          footnote_class.new(id: "0", type: "continuationSeparator", paragraphs: []),
          footnote_class.new(id: "1", paragraphs: [para_class.new]),
          footnote_class.new(id: "2", paragraphs: [para_class.new]),
          footnote_class.new(id: "3", paragraphs: [para_class.new]),
        ],
      )
      package = build_package_with_refs(
        ref_ids_in_paras: ["1"],
        ref_ids_in_tables: ["2", "3"],
      )
      package.footnotes = footnotes

      reconciler = described_class.new(package)
      reconciler.reconcile

      expect(package.footnotes.footnote_entries.map(&:id)).to include("1", "2", "3")
    end

    it "creates missing footnote definitions for references in table cells" do
      package = build_package_with_refs(
        ref_ids_in_paras: ["1"],
        ref_ids_in_tables: ["2", "99"],
      )
      package.footnotes = footnotes_class.new(
        footnote_entries: [
          footnote_class.new(id: "-1", type: "separator", paragraphs: []),
          footnote_class.new(id: "0", type: "continuationSeparator", paragraphs: []),
          footnote_class.new(id: "1", paragraphs: [para_class.new]),
        ],
      )

      reconciler = described_class.new(package)
      reconciler.reconcile

      ids = package.footnotes.footnote_entries.map(&:id)
      expect(ids).to include("99")
      r10 = reconciler.applied_fixes.find { |f| f.code == "R10" }
      expect(r10).not_to be_nil
      expect(r10.message).to include("99")
    end

    it "creates footnotes.xml when references exist but no footnotes part" do
      package = build_package_with_refs(ref_ids_in_paras: ["1"])

      reconciler = described_class.new(package)
      reconciler.reconcile

      expect(package.footnotes).to be_a(footnotes_class)
      ids = package.footnotes.footnote_entries.map(&:id)
      expect(ids).to include("-1", "0", "1")
    end

    it "returns empty when no footnote references exist" do
      document = Uniword::Wordprocessingml::DocumentRoot.new
      document.body = body_class.new
      package = Uniword::Docx::Package.new
      package.document = document

      reconciler = described_class.new(package)
      reconciler.reconcile

      r10 = reconciler.applied_fixes.find { |f| f.code == "R10" }
      expect(r10).to be_nil
    end
  end

  describe "note definition integrity (R15, R16)" do
    def build_package_with_footnotes(footnote_entries)
      document = Uniword::Wordprocessingml::DocumentRoot.new
      document.body = Uniword::Wordprocessingml::Body.new
      package = Uniword::Docx::Package.new
      package.document = document
      package.footnotes = footnotes_class.new(
        footnote_entries: footnote_entries,
      )
      package
    end

    def build_package_with_endnotes(endnote_entries)
      document = Uniword::Wordprocessingml::DocumentRoot.new
      document.body = Uniword::Wordprocessingml::Body.new
      package = Uniword::Docx::Package.new
      package.document = document
      package.endnotes = endnotes_class.new(
        endnote_entries: endnote_entries,
      )
      package
    end

    describe "R15: strip_invalid_note_types" do
      it "removes w:type from regular footnote definitions" do
        package = build_package_with_footnotes([
          footnote_class.new(id: "-1", type: "separator", paragraphs: []),
          footnote_class.new(id: "0", type: "continuationSeparator", paragraphs: []),
          footnote_class.new(id: "1", type: "normal", paragraphs: [para_class.new]),
          footnote_class.new(id: "2", type: "someOtherType", paragraphs: [para_class.new]),
        ])

        reconciler = described_class.new(package)
        reconciler.reconcile

        entries = package.footnotes.footnote_entries
        expect(entries.find { |e| e.id == "1" }.type).to be_nil
        expect(entries.find { |e| e.id == "2" }.type).to be_nil

        r15 = reconciler.applied_fixes.find { |f| f.code == "R15" }
        expect(r15).not_to be_nil
        expect(r15.message).to include("2")
        expect(r15.message).to include("1", "2")
      end

      it "preserves w:type on separator and continuation entries" do
        package = build_package_with_footnotes([
          footnote_class.new(id: "-1", type: "separator", paragraphs: []),
          footnote_class.new(id: "0", type: "continuationSeparator", paragraphs: []),
          footnote_class.new(id: "1", paragraphs: [para_class.new]),
        ])

        reconciler = described_class.new(package)
        reconciler.reconcile

        entries = package.footnotes.footnote_entries
        expect(entries.find { |e| e.id == "-1" }.type).to eq("separator")
        expect(entries.find { |e| e.id == "0" }.type).to eq("continuationSeparator")
        expect(entries.find { |e| e.id == "1" }.type).to be_nil

        r15 = reconciler.applied_fixes.find { |f| f.code == "R15" }
        expect(r15).to be_nil
      end

      it "removes w:type from regular endnote definitions" do
        package = build_package_with_endnotes([
          endnote_class.new(id: "-1", type: "separator", paragraphs: []),
          endnote_class.new(id: "0", type: "continuationSeparator", paragraphs: []),
          endnote_class.new(id: "1", type: "normal", paragraphs: [para_class.new]),
        ])

        reconciler = described_class.new(package)
        reconciler.reconcile

        expect(package.endnotes.endnote_entries.find { |e| e.id == "1" }.type).to be_nil
        r15 = reconciler.applied_fixes.select { |f| f.code == "R15" }
        expect(r15.size).to eq(1)
        expect(r15.first.message).to include("endnote")
      end

      it "does nothing when no invalid types exist" do
        package = build_package_with_footnotes([
          footnote_class.new(id: "-1", type: "separator", paragraphs: []),
          footnote_class.new(id: "0", type: "continuationSeparator", paragraphs: []),
          footnote_class.new(id: "1", paragraphs: [para_class.new]),
        ])

        reconciler = described_class.new(package)
        reconciler.reconcile

        r15 = reconciler.applied_fixes.select { |f| f.code == "R15" }
        expect(r15).to be_empty
      end

      it "does nothing when footnotes and endnotes are nil" do
        document = Uniword::Wordprocessingml::DocumentRoot.new
        document.body = Uniword::Wordprocessingml::Body.new
        package = Uniword::Docx::Package.new
        package.document = document

        reconciler = described_class.new(package)
        reconciler.reconcile

        r15 = reconciler.applied_fixes.select { |f| f.code == "R15" }
        expect(r15).to be_empty
      end
    end

    describe "R16: deduplicate_note_ids" do
      it "removes duplicate footnote IDs keeping first occurrence" do
        package = build_package_with_footnotes([
          footnote_class.new(id: "-1", type: "separator", paragraphs: []),
          footnote_class.new(id: "0", type: "continuationSeparator", paragraphs: []),
          footnote_class.new(id: "1", paragraphs: [para_class.new]),
          footnote_class.new(id: "2", paragraphs: [para_class.new]),
          footnote_class.new(id: "1", paragraphs: [para_class.new]),
          footnote_class.new(id: "3", paragraphs: [para_class.new]),
          footnote_class.new(id: "2", paragraphs: [para_class.new]),
        ])

        reconciler = described_class.new(package)
        reconciler.reconcile

        ids = package.footnotes.footnote_entries.map(&:id)
        expect(ids).to eq(["-1", "0", "1", "2", "3"])
        expect(ids.uniq).to eq(ids)

        r16 = reconciler.applied_fixes.find { |f| f.code == "R16" }
        expect(r16).not_to be_nil
        expect(r16.message).to include("2")
        expect(r16.message).to include("1", "2")
      end

      it "removes duplicate endnote IDs" do
        package = build_package_with_endnotes([
          endnote_class.new(id: "-1", type: "separator", paragraphs: []),
          endnote_class.new(id: "0", type: "continuationSeparator", paragraphs: []),
          endnote_class.new(id: "1", paragraphs: [para_class.new]),
          endnote_class.new(id: "1", paragraphs: [para_class.new]),
        ])

        reconciler = described_class.new(package)
        reconciler.reconcile

        ids = package.endnotes.endnote_entries.map(&:id)
        expect(ids).to eq(["-1", "0", "1"])

        r16 = reconciler.applied_fixes.select { |f| f.code == "R16" }
        expect(r16.size).to eq(1)
        expect(r16.first.message).to include("endnote")
      end

      it "does nothing when no duplicates exist" do
        package = build_package_with_footnotes([
          footnote_class.new(id: "-1", type: "separator", paragraphs: []),
          footnote_class.new(id: "0", type: "continuationSeparator", paragraphs: []),
          footnote_class.new(id: "1", paragraphs: [para_class.new]),
          footnote_class.new(id: "2", paragraphs: [para_class.new]),
        ])

        reconciler = described_class.new(package)
        reconciler.reconcile

        r16 = reconciler.applied_fixes.select { |f| f.code == "R16" }
        expect(r16).to be_empty
      end

      it "does nothing when footnotes and endnotes are nil" do
        document = Uniword::Wordprocessingml::DocumentRoot.new
        document.body = Uniword::Wordprocessingml::Body.new
        package = Uniword::Docx::Package.new
        package.document = document

        reconciler = described_class.new(package)
        reconciler.reconcile

        r16 = reconciler.applied_fixes.select { |f| f.code == "R16" }
        expect(r16).to be_empty
      end
    end
  end

  describe "notes: reorder by reference order" do
    let(:run_class) { Uniword::Wordprocessingml::Run }
    let(:text_class) { Uniword::Wordprocessingml::Text }
    let(:para_class) { Uniword::Wordprocessingml::Paragraph }
    let(:fn_ref_class) { Uniword::Wordprocessingml::FootnoteReference }

    it "reorders footnotes to match body reference order" do
      package = Uniword::Docx::Package.new
      package.document = Uniword::Wordprocessingml::DocumentRoot.new

      # Paragraph references footnote 2 first, then 1
      run2 = run_class.new(
        text: text_class.new(value: "text2"),
        footnote_reference: fn_ref_class.new(id: "2"),
      )
      run1 = run_class.new(
        text: text_class.new(value: "text1"),
        footnote_reference: fn_ref_class.new(id: "1"),
      )
      para = para_class.new(runs: [run2, run1])
      package.document.body.paragraphs << para

      settings = settings_class.new
      settings.footnote_pr = footnote_pr_class.new
      package.settings = settings

      # Footnotes stored in order 1, 2 (wrong order relative to body)
      footnotes = footnotes_class.new(
        footnote_entries: [
          footnote_class.new(id: "-1", type: "separator", paragraphs: []),
          footnote_class.new(id: "0", type: "continuationSeparator", paragraphs: []),
          footnote_class.new(id: "1", paragraphs: [para_class.new(runs: [run_class.new(text: text_class.new(value: "fn1"))])]),
          footnote_class.new(id: "2", paragraphs: [para_class.new(runs: [run_class.new(text: text_class.new(value: "fn2"))])]),
        ],
      )
      package.footnotes = footnotes

      described_class.new(package).reconcile

      user_entries = footnotes.footnote_entries.reject { |e| %w[separator continuationSeparator footnoteSeparator continuationNotice].include?(e.type) }
      expect(user_entries.map(&:id)).to eq(%w[1 2])
    end
  end

  describe "referential integrity" do
    let(:run_class) { Uniword::Wordprocessingml::Run }
    let(:text_class) { Uniword::Wordprocessingml::Text }
    let(:fn_ref_class) { Uniword::Wordprocessingml::FootnoteReference }
    let(:en_ref_class) { Uniword::Wordprocessingml::EndnoteReference }

    def build_package_with_body_paragraphs(*paras)
      package = Uniword::Docx::Package.new
      package.document = Uniword::Wordprocessingml::DocumentRoot.new
      paras.each { |p| package.document.body.paragraphs << p }
      package
    end

    it "creates missing footnote definition for dangling reference" do
      run = run_class.new(
        text: text_class.new(value: "text"),
        footnote_reference: fn_ref_class.new(id: "99"),
      )
      para = para_class.new(runs: [run])
      package = build_package_with_body_paragraphs(para)

      settings = settings_class.new
      settings.footnote_pr = footnote_pr_class.new
      package.settings = settings

      reconciler = described_class.new(package)
      reconciler.reconcile

      expect(package.footnotes.footnote_entries.map(&:id)).to include("99")
      r10 = reconciler.applied_fixes.find { |f| f.code == "R10" }
      expect(r10).not_to be_nil
    end

    it "creates missing endnote definition for dangling reference" do
      run = run_class.new(
        text: text_class.new(value: "text"),
        endnote_reference: en_ref_class.new(id: "99"),
      )
      para = para_class.new(runs: [run])
      package = build_package_with_body_paragraphs(para)

      settings = settings_class.new
      settings.endnote_pr = endnote_pr_class.new
      package.settings = settings

      reconciler = described_class.new(package)
      reconciler.reconcile

      expect(package.endnotes.endnote_entries.map(&:id)).to include("99")
      r10 = reconciler.applied_fixes.find { |f| f.code == "R10" }
      expect(r10).not_to be_nil
    end
  end
end
