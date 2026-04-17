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

  def build_package(settings: nil, footnotes: nil, endnotes: nil)
    package = instance_double(Uniword::Docx::Package)
    allow(package).to receive(:settings).and_return(settings)
    allow(package).to receive(:footnotes).and_return(footnotes)
    allow(package).to receive(:endnotes).and_return(endnotes)
    allow(package).to receive(:footnotes=)
    allow(package).to receive(:endnotes=)
    allow(package).to receive(:settings=)
    if settings
      allow(settings).to receive(:footnote_pr=)
      allow(settings).to receive(:endnote_pr=)
    end
    package
  end

  describe "footnotes reconciliation" do
    it "creates minimal footnotes when footnote_pr is set but footnotes is nil" do
      settings = settings_class.new
      settings.footnote_pr = footnote_pr_class.new
      package = build_package(settings: settings, footnotes: nil, endnotes: nil)

      reconciler = described_class.new(package)
      reconciler.reconcile

      expect(package).to have_received(:footnotes=).with(
        satisfy { |fn| fn.is_a?(footnotes_class) && fn.footnote_entries.size == 2 }
      )
    end

    it "creates footnote_pr when footnotes exist but footnote_pr is nil" do
      settings = settings_class.new
      footnotes = footnotes_class.new(
        footnote_entries: [
          footnote_class.new(id: "1", paragraphs: [])
        ]
      )
      package = build_package(settings: settings, footnotes: footnotes, endnotes: nil)

      reconciler = described_class.new(package)
      reconciler.reconcile

      expect(settings).to have_received(:footnote_pr=).with(
        satisfy { |pr| pr.is_a?(footnote_pr_class) }
      )
    end

    it "does not change when both footnote_pr and footnotes are set" do
      settings = settings_class.new
      settings.footnote_pr = footnote_pr_class.new
      footnotes = footnotes_class.new(
        footnote_entries: [
          footnote_class.new(id: "-1", type: "separator", paragraphs: []),
          footnote_class.new(id: "0", type: "continuationSeparator", paragraphs: []),
          footnote_class.new(id: "1", paragraphs: [])
        ]
      )
      package = build_package(settings: settings, footnotes: footnotes, endnotes: nil)

      reconciler = described_class.new(package)
      reconciler.reconcile

      expect(package).not_to have_received(:footnotes=)
      expect(settings).not_to have_received(:footnote_pr=)
    end

    it "does not change when neither footnote_pr nor footnotes are set" do
      settings = settings_class.new
      package = build_package(settings: settings, footnotes: nil, endnotes: nil)

      reconciler = described_class.new(package)
      reconciler.reconcile

      expect(package).not_to have_received(:footnotes=)
      expect(settings).not_to have_received(:footnote_pr=)
    end

    it "injects missing separator entry (id=-1)" do
      settings = settings_class.new
      settings.footnote_pr = footnote_pr_class.new
      footnotes = footnotes_class.new(
        footnote_entries: [
          footnote_class.new(id: "0", type: "continuationSeparator", paragraphs: []),
          footnote_class.new(id: "1", paragraphs: [])
        ]
      )
      package = build_package(settings: settings, footnotes: footnotes, endnotes: nil)

      reconciler = described_class.new(package)
      reconciler.reconcile

      ids = footnotes.footnote_entries.map(&:id)
      expect(ids).to include("-1")
    end

    it "injects missing continuation entry (id=0)" do
      settings = settings_class.new
      settings.footnote_pr = footnote_pr_class.new
      footnotes = footnotes_class.new(
        footnote_entries: [
          footnote_class.new(id: "-1", type: "separator", paragraphs: []),
          footnote_class.new(id: "1", paragraphs: [])
        ]
      )
      package = build_package(settings: settings, footnotes: footnotes, endnotes: nil)

      reconciler = described_class.new(package)
      reconciler.reconcile

      ids = footnotes.footnote_entries.map(&:id)
      expect(ids).to include("0")
    end
  end

  describe "endnotes reconciliation" do
    it "creates minimal endnotes when endnote_pr is set but endnotes is nil" do
      settings = settings_class.new
      settings.endnote_pr = endnote_pr_class.new
      package = build_package(settings: settings, footnotes: nil, endnotes: nil)

      reconciler = described_class.new(package)
      reconciler.reconcile

      expect(package).to have_received(:endnotes=).with(
        satisfy { |en| en.is_a?(endnotes_class) && en.endnote_entries.size == 2 }
      )
    end

    it "creates endnote_pr when endnotes exist but endnote_pr is nil" do
      settings = settings_class.new
      endnotes = endnotes_class.new(
        endnote_entries: [
          endnote_class.new(id: "1", paragraphs: [])
        ]
      )
      package = build_package(settings: settings, footnotes: nil, endnotes: endnotes)

      reconciler = described_class.new(package)
      reconciler.reconcile

      expect(settings).to have_received(:endnote_pr=).with(
        satisfy { |pr| pr.is_a?(endnote_pr_class) }
      )
    end

    it "does not change when both endnote_pr and endnotes are set" do
      settings = settings_class.new
      settings.endnote_pr = endnote_pr_class.new
      endnotes = endnotes_class.new(
        endnote_entries: [
          endnote_class.new(id: "-1", type: "separator", paragraphs: []),
          endnote_class.new(id: "0", type: "continuationSeparator", paragraphs: []),
          endnote_class.new(id: "1", paragraphs: [])
        ]
      )
      package = build_package(settings: settings, footnotes: nil, endnotes: endnotes)

      reconciler = described_class.new(package)
      reconciler.reconcile

      expect(package).not_to have_received(:endnotes=)
      expect(settings).not_to have_received(:endnote_pr=)
    end

    it "does not change when neither endnote_pr nor endnotes are set" do
      settings = settings_class.new
      package = build_package(settings: settings, footnotes: nil, endnotes: nil)

      reconciler = described_class.new(package)
      reconciler.reconcile

      expect(package).not_to have_received(:endnotes=)
      expect(settings).not_to have_received(:endnote_pr=)
    end

    it "injects missing separator entry (id=-1)" do
      settings = settings_class.new
      settings.endnote_pr = endnote_pr_class.new
      endnotes = endnotes_class.new(
        endnote_entries: [
          endnote_class.new(id: "0", type: "continuationSeparator", paragraphs: []),
          endnote_class.new(id: "1", paragraphs: [])
        ]
      )
      package = build_package(settings: settings, footnotes: nil, endnotes: endnotes)

      reconciler = described_class.new(package)
      reconciler.reconcile

      ids = endnotes.endnote_entries.map(&:id)
      expect(ids).to include("-1")
    end

    it "injects missing continuation entry (id=0)" do
      settings = settings_class.new
      settings.endnote_pr = endnote_pr_class.new
      endnotes = endnotes_class.new(
        endnote_entries: [
          endnote_class.new(id: "-1", type: "separator", paragraphs: []),
          endnote_class.new(id: "1", paragraphs: [])
        ]
      )
      package = build_package(settings: settings, footnotes: nil, endnotes: endnotes)

      reconciler = described_class.new(package)
      reconciler.reconcile

      ids = endnotes.endnote_entries.map(&:id)
      expect(ids).to include("0")
    end
  end
end
