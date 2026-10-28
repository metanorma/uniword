# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Batch::Operation::Report do
  it "aggregates success and failure counts" do
    report = described_class.new(operation_name: :repair)
    report.add(Uniword::Batch::Operation::FileResult.new(path: "a.docx",
                                                         status: :success,
                                                         metric: 5))
    report.add(Uniword::Batch::Operation::FileResult.new(path: "b.docx",
                                                         status: :failure,
                                                         error: "boom"))
    expect(report.count).to eq(2)
    expect(report.success_count).to eq(1)
    expect(report.failure_count).to eq(1)
    expect(report.total_metric).to eq(5)
    expect(report.failed_paths).to eq(["b.docx"])
  end
end

RSpec.describe Uniword::Batch::Operation::Runner do
  let(:task_class) do
    Class.new(Uniword::Batch::Operation::Task) do
      def name; :counting; end

      def run(path)
        success(path: path, metric: 1)
      end
    end
  end

  it "runs the task for each path" do
    runner = described_class.new(task: task_class.new,
                                 paths: %w[a.docx b.docx c.docx])
    report = runner.run
    expect(report.count).to eq(3)
    expect(report.all_success?).to be(true)
    expect(report.total_metric).to eq(3)
  end

  it "aggregates failures without stopping" do
    failing_task = Class.new(Uniword::Batch::Operation::Task) do
      def name; :flaky; end

      def run(path)
        return failure(path: path, error: "bad") if path == "b.docx"

        success(path: path)
      end
    end.new
    runner = described_class.new(task: failing_task,
                                 paths: %w[a.docx b.docx c.docx])
    report = runner.run
    expect(report.success_count).to eq(2)
    expect(report.failure_count).to eq(1)
  end
end

RSpec.describe Uniword::Batch::Operation::FileResult do
  it "exposes success? based on status" do
    success = described_class.new(path: "x", status: :success)
    failure = described_class.new(path: "x", status: :failure)
    expect(success).to be_success
    expect(failure).not_to be_success
  end
end
