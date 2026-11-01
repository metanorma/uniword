# frozen_string_literal: true

require "spec_helper"
require "zip"

# CLI coverage for `uniword revisions` - the issue-#79 alias of the
# review tracked-changes verbs.
RSpec.describe "uniword revisions" do
  let(:cli) { Uniword::RevisionsCLI.new }
  let(:output_dir) { "tmp/revisions_cli_spec" }
  let(:input_path) { File.join(output_dir, "rev.docx") }
  let(:output_path) { File.join(output_dir, "accepted.docx") }

  def write_doc_with_deletion(path)
    deletion = Uniword::Wordprocessingml::Deletion.new(
      id: "7", author: "Alice", date: "2026-01-02T00:00:00Z",
      runs: [Uniword::Wordprocessingml::Run.new(
        del_text: Uniword::Wordprocessingml::DeletedText.new(
          content: "drop this",
        ),
      )],
    )
    Uniword::Builder::DocumentBuilder.new.tap do |builder|
      para = builder.paragraph("keep this drop this")
      para.model.deletions << deletion
    end.save(path)
  end

  before do
    FileUtils.mkdir_p(output_dir)
    write_doc_with_deletion(input_path)
  end

  after do
    Dir.glob("#{output_dir}/*.docx").each { |f| safe_delete(f) }
  end

  it "lists revisions like review changes" do
    expect { cli.invoke(:list, [input_path]) }
      .to output(/Tracked changes \(1\)/).to_stdout
  end

  it "lists revisions as JSON" do
    expect { cli.invoke(:list, [input_path], json: true) }
      .to output(/"author": "Alice"/).to_stdout
  end

  it "accepts revisions via the alias" do
    expect { cli.invoke(:accept, [input_path], output: output_path) }
      .to output(/accept/i).to_stdout

    xml = Zip::File.open(output_path) { |zip| zip.read("word/document.xml") }
    expect(xml).not_to include("<w:del ")
    expect(xml).to include("keep this")
  end

  it "rejects revisions via the alias" do
    expect { cli.invoke(:reject, [input_path], output: output_path) }
      .to output(/reject/i).to_stdout

    reloaded = Uniword::DocumentFactory.from_file(output_path)
    expect(reloaded.body.paragraphs.sum { |p| p.deletions.size }).to eq(0)
    expect(reloaded.body.paragraphs.flat_map(&:runs).map(&:text_string))
      .to include("drop this")
  end

  it "is registered on the main CLI as a group" do
    expect { Uniword::CLI.new.invoke(:revisions, []) }
      .to output(/revisions list|Commands:/).to_stdout
  end
end
