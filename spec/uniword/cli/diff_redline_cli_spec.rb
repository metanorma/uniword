# frozen_string_literal: true

require "spec_helper"
require "zip"

# CLI coverage for `uniword diff redline` — tracked-changes output.
RSpec.describe "uniword diff redline" do
  let(:cli) { Uniword::DiffCLI.new }
  let(:output_dir) { "tmp/diff_redline_cli_spec" }
  let(:old_path) { File.join(output_dir, "old.docx") }
  let(:new_path) { File.join(output_dir, "new.docx") }
  let(:out_path) { File.join(output_dir, "redline.docx") }

  def write_doc(path, texts)
    doc = Uniword::Wordprocessingml::DocumentRoot.new
    doc.body = Uniword::Wordprocessingml::Body.new
    texts.each do |text|
      doc.body.paragraphs << Uniword::Wordprocessingml::Paragraph.new(
        runs: [Uniword::Wordprocessingml::Run.new(text: text)],
      )
    end
    doc.save(path)
  end

  before do
    FileUtils.mkdir_p(output_dir)
    write_doc(old_path, ["Alpha line.", "Beta line."])
    write_doc(new_path, ["Alpha line!", "Beta line."])
  end

  after do
    Dir.glob("#{output_dir}/*.docx").each { |f| safe_delete(f) }
  end

  it "writes a redline document and reports the changes" do
    expect do
      cli.invoke(:redline, [old_path, new_path],
                 output: out_path)
    end.to output(/Redline written to #{Regexp.escape(out_path)}/).to_stdout

    xml = Zip::File.open(out_path) { |zip| zip.read("word/document.xml") }
    expect(xml).to include("<w:ins ")
    expect(xml).to include("<w:delText")
  end

  it "emits a JSON summary" do
    expect do
      cli.invoke(:redline, [old_path, new_path],
                 output: out_path, json: true)
    end.to output(/"insertions"/).to_stdout
  end

  it "derives the default output path from the base document" do
    expect { cli.invoke(:redline, [old_path, new_path]) }
      .to output(/old\.redline\.docx/).to_stdout
    expect(File).to exist(File.join(output_dir, "old.redline.docx"))
  end

  # Exit statuses cannot be asserted in-process (SystemExit from the
  # Thor command), so the missing-input case spawns the real binary.
  it "exits 1 when an input file is missing" do
    require "open3"
    exe = File.expand_path("../../../exe/uniword", __dir__)
    _out, _err, status = Open3.capture3(
      RbConfig.ruby, exe, "diff", "redline",
      File.join(output_dir, "gone.docx"), new_path
    )
    expect(status.exitstatus).to eq(1)
  end
end
