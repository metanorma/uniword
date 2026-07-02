# frozen_string_literal: true

require "spec_helper"
require "uniword/docx"

RSpec.describe Uniword::Docx::Reconciler::Helpers do
  let(:package) { Uniword::Docx::Package.new }
  let(:reconciler) { Uniword::Docx::Reconciler.new(package) }
  let(:document) { Uniword::Wordprocessingml::DocumentRoot.new }
  let(:body) { Uniword::Wordprocessingml::Body.new }

  before do
    document.body = body
    package.document = document
  end

  shared_examples "a reconciler helper" do
    it { expect(reconciler).to be_a(Uniword::Docx::Reconciler) }
  end

  describe "#generate_rsid" do
    it "returns uppercase hex string" do
      expect(reconciler.generate_rsid).to match(/\A[0-9A-F]+\z/i)
    end

    it "is deterministic across calls" do
      a = reconciler.generate_rsid
      b = reconciler.generate_rsid
      expect(a).to eq(b)
    end
  end

  describe "#generate_hex_id" do
    it "returns 8 hex chars by default" do
      expect(reconciler.generate_hex_id.length).to eq(8)
    end

    it "is deterministic for the same input" do
      a = reconciler.generate_hex_id("test")
      b = reconciler.generate_hex_id("test")
      expect(a).to eq(b)
    end
  end

  describe "#hex_derive(seed, byte_count)" do
    it "returns 2x byte_count hex chars" do
      expect(reconciler.hex_derive("w14_doc_id", 4).length).to eq(8)
    end

    it "is deterministic" do
      a = reconciler.hex_derive("anything", 4)
      b = reconciler.hex_derive("anything", 4)
      expect(a).to eq(b)
    end
  end

  describe "#walk_body_paragraphs" do
    it "yields each top-level paragraph when element_order is nil" do
      body.paragraphs << Uniword::Wordprocessingml::Paragraph.new
      body.paragraphs << Uniword::Wordprocessingml::Paragraph.new

      expect { |b| reconciler.walk_body_paragraphs(body, &b) }
        .to yield_control.exactly(2).times
    end

    it "yields paragraphs from inside tables via walk_table_paragraphs" do
      para_in_cell = Uniword::Wordprocessingml::Paragraph.new
      cell = Uniword::Wordprocessingml::TableCell.new(paragraphs: [para_in_cell])
      row = Uniword::Wordprocessingml::TableRow.new(cells: [cell])
      table = Uniword::Wordprocessingml::Table.new(rows: [row])
      body.tables << table

      yielded = []
      reconciler.walk_body_paragraphs(body) { |p| yielded << p }
      expect(yielded).to include(para_in_cell)
    end
  end

  describe "#walk_body_tables" do
    it "yields each top-level table" do
      t1 = Uniword::Wordprocessingml::Table.new
      t2 = Uniword::Wordprocessingml::Table.new
      body.tables << t1
      body.tables << t2

      expect { |b| reconciler.walk_body_tables(body, &b) }
        .to yield_successive_args(t1, t2)
    end

    it "yields nothing when body has no tables" do
      expect { |b| reconciler.walk_body_tables(body, &b) }
        .not_to yield_control
    end

    it "returns early when body is nil" do
      expect { |b| reconciler.walk_body_tables(nil, &b) }
        .not_to yield_control
    end
  end

  describe "#empty_run?" do
    it "returns true for a run with no content" do
      run = Uniword::Wordprocessingml::Run.new
      expect(reconciler.empty_run?(run)).to be true
    end

    it "returns false for a run with text" do
      run = Uniword::Wordprocessingml::Run.new(
        text: Uniword::Wordprocessingml::Text.new(content: "hi"),
      )
      expect(reconciler.empty_run?(run)).to be false
    end

    it "returns false for a run with a break" do
      run = Uniword::Wordprocessingml::Run.new(
        break: Uniword::Wordprocessingml::Break.new,
      )
      expect(reconciler.empty_run?(run)).to be false
    end

    it "returns false for a run with a tab" do
      run = Uniword::Wordprocessingml::Run.new(
        tab: Uniword::Wordprocessingml::Tab.new,
      )
      expect(reconciler.empty_run?(run)).to be false
    end
  end

  describe "#strip_empty_runs" do
    it "removes empty runs from a paragraph" do
      empty = Uniword::Wordprocessingml::Run.new
      text_run = Uniword::Wordprocessingml::Run.new(
        text: Uniword::Wordprocessingml::Text.new(content: "kept"),
      )
      para = Uniword::Wordprocessingml::Paragraph.new(runs: [empty, text_run])

      reconciler.strip_empty_runs(para)

      expect(para.runs).to eq([text_run])
    end

    it "records a fix entry when runs are removed" do
      para = Uniword::Wordprocessingml::Paragraph.new(
        runs: [Uniword::Wordprocessingml::Run.new],
      )

      reconciler.strip_empty_runs(para)

      expect(reconciler.applied_fixes.map { |f| f[:validity_rule] })
        .to include(Uniword::Docx::Reconciler::FixCodes::EMPTY_RUNS_STRIPPED)
    end

    it "does not record a fix when nothing was removed" do
      para = Uniword::Wordprocessingml::Paragraph.new(
        runs: [Uniword::Wordprocessingml::Run.new(
          text: Uniword::Wordprocessingml::Text.new(content: "kept"),
        )],
      )

      reconciler.strip_empty_runs(para)

      expect(reconciler.applied_fixes).to be_empty
    end
  end

  describe "#ensure_element_in_order" do
    it "appends when after/before are not specified" do
      model = Uniword::Wordprocessingml::Settings.new
      model.element_order = []

      reconciler.ensure_element_in_order(model, "zoom")

      expect(model.element_order.map(&:name)).to include("zoom")
    end

    it "returns early when tag already present" do
      model = Uniword::Wordprocessingml::Settings.new
      model.element_order = [
        Lutaml::Xml::Element.new("Element", "zoom"),
      ]

      expect { reconciler.ensure_element_in_order(model, "zoom") }
        .not_to(change { model.element_order.size })
    end

    it "returns early when element_order is nil" do
      model = Uniword::Wordprocessingml::Settings.new
      model.element_order = nil

      reconciler.ensure_element_in_order(model, "zoom")

      expect(model.element_order).to be_nil
    end
  end

  describe "note-type dispatch helpers" do
    describe "#notes_collection_for" do
      it "returns package.footnotes for :footnote" do
        fns = Uniword::Wordprocessingml::Footnotes.new
        package.footnotes = fns

        expect(reconciler.notes_collection_for(:footnote)).to equal(fns)
      end

      it "returns package.endnotes for :endnote" do
        ens = Uniword::Wordprocessingml::Endnotes.new
        package.endnotes = ens

        expect(reconciler.notes_collection_for(:endnote)).to equal(ens)
      end
    end

    describe "#note_entries_for" do
      it "returns footnote_entries from a Footnotes collection" do
        fns = Uniword::Wordprocessingml::Footnotes.new(
          footnote_entries: [Uniword::Wordprocessingml::Footnote.new(id: "1")],
        )
        expect(reconciler.note_entries_for(fns, :footnote).map(&:id))
          .to eq(["1"])
      end

      it "returns endnote_entries from an Endnotes collection" do
        ens = Uniword::Wordprocessingml::Endnotes.new(
          endnote_entries: [Uniword::Wordprocessingml::Endnote.new(id: "1")],
        )
        expect(reconciler.note_entries_for(ens, :endnote).map(&:id))
          .to eq(["1"])
      end

      it "returns empty array when notes is nil" do
        expect(reconciler.note_entries_for(nil, :footnote)).to eq([])
      end
    end

    describe "#note_reference_from_run" do
      it "returns footnote_reference for :footnote" do
        ref = Uniword::Wordprocessingml::FootnoteReference.new(id: "1")
        run = Uniword::Wordprocessingml::Run.new(footnote_reference: ref)

        expect(reconciler.note_reference_from_run(run, :footnote)).to equal(ref)
      end

      it "returns endnote_reference for :endnote" do
        ref = Uniword::Wordprocessingml::EndnoteReference.new(id: "1")
        run = Uniword::Wordprocessingml::Run.new(endnote_reference: ref)

        expect(reconciler.note_reference_from_run(run, :endnote)).to equal(ref)
      end
    end

    describe "#build_notes_collection" do
      it "builds a Footnotes for :footnote" do
        entries = [Uniword::Wordprocessingml::Footnote.new(id: "-1")]
        result = reconciler.build_notes_collection(:footnote, entries: entries)

        expect(result).to be_a(Uniword::Wordprocessingml::Footnotes)
        expect(result.footnote_entries).to eq(entries)
      end

      it "builds an Endnotes for :endnote" do
        entries = [Uniword::Wordprocessingml::Endnote.new(id: "-1")]
        result = reconciler.build_notes_collection(:endnote, entries: entries)

        expect(result).to be_a(Uniword::Wordprocessingml::Endnotes)
        expect(result.endnote_entries).to eq(entries)
      end
    end

    describe "#assign_note_pr" do
      it "sets footnote_pr on settings for :footnote" do
        settings = Uniword::Wordprocessingml::Settings.new

        reconciler.assign_note_pr(settings, :footnote)

        expect(settings.footnote_pr).to be_a(Uniword::Wordprocessingml::FootnotePr)
      end

      it "sets endnote_pr on settings for :endnote" do
        settings = Uniword::Wordprocessingml::Settings.new

        reconciler.assign_note_pr(settings, :endnote)

        expect(settings.endnote_pr).to be_a(Uniword::Wordprocessingml::EndnotePr)
      end
    end

    describe "#set_notes_collection" do
      it "assigns to package.footnotes for :footnote" do
        fns = Uniword::Wordprocessingml::Footnotes.new

        reconciler.set_notes_collection(fns, :footnote)

        expect(package.footnotes).to equal(fns)
      end

      it "assigns to package.endnotes for :endnote" do
        ens = Uniword::Wordprocessingml::Endnotes.new

        reconciler.set_notes_collection(ens, :endnote)

        expect(package.endnotes).to equal(ens)
      end
    end
  end
end
