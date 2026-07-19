# frozen_string_literal: true

require "spec_helper"

# CLI coverage for `uniword styles list` — Word's Styles pane as a
# terminal listing.
RSpec.describe Uniword::StylesCLI do
  let(:cli) { described_class.new }
  let(:fixture) { "spec/fixtures/docx_gem/test_with_style.docx" }

  describe "#list" do
    it "lists styles with id, type and base" do
      expect { cli.invoke(:list, [fixture]) }
        .to output(/Styles in test_with_style\.docx \(\d+\):/).to_stdout
    end

    it "filters by type" do
      expect { cli.invoke(:list, [fixture], type: "table") }
        .to output(/table/).to_stdout
    end

    it "shows formatting details with --verbose" do
      expect { cli.invoke(:list, [fixture], verbose: true) }
        .to output(/name=/).to_stdout
    end
  end
end
