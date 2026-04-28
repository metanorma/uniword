# frozen_string_literal: true

require "spec_helper"
require "uniword/logger"

RSpec.describe Uniword do
  describe ".logger" do
    it "returns a Logger instance" do
      expect(described_class.logger).to be_a(Logger)
    end

    it "uses WARN level by default" do
      # Reset to default
      described_class.logger = nil
      expect(described_class.logger.level).to eq(Logger::WARN)
    end
  end

  describe ".debug?" do
    it "returns true when debug level is set" do
      described_class.logger.level = Logger::DEBUG
      expect(described_class.debug?).to be true
    end

    it "returns false when not debug level" do
      described_class.logger.level = Logger::WARN
      expect(described_class.debug?).to be false
    end
  end

  describe ".enable_debug_logging" do
    it "sets logger to DEBUG level" do
      described_class.enable_debug_logging
      expect(described_class.logger.level).to eq(Logger::DEBUG)
    end
  end

  describe ".disable_debug_logging" do
    it "sets logger to WARN level" do
      described_class.disable_debug_logging
      expect(described_class.logger.level).to eq(Logger::WARN)
    end
  end

  describe "custom logger" do
    it "allows setting a custom logger" do
      custom_logger = Logger.new(StringIO.new)
      described_class.logger = custom_logger
      expect(described_class.logger).to eq(custom_logger)
    end
  end
end

RSpec.describe Uniword::Loggable do
  let(:test_class) do
    Class.new do
      include Uniword::Loggable

      def test_logging
        log_debug("Debug message")
        log_info("Info message")
        log_warn("Warning message")
        log_error("Error message")
      end
    end
  end

  let(:instance) { test_class.new }

  describe "#logger" do
    it "returns the Uniword logger" do
      expect(instance.logger).to eq(Uniword.logger)
    end
  end

  describe "logging methods" do
    let(:string_io) { StringIO.new }
    let(:test_logger) { Logger.new(string_io) }

    before do
      Uniword.logger = test_logger
      Uniword.logger.level = Logger::DEBUG
    end

    it "logs debug messages" do
      instance.log_debug("Test debug")
      expect(string_io.string).to include("DEBUG")
      expect(string_io.string).to include("Test debug")
    end

    it "logs info messages" do
      instance.log_info("Test info")
      expect(string_io.string).to include("INFO")
      expect(string_io.string).to include("Test info")
    end

    it "logs warning messages" do
      instance.log_warn("Test warning")
      expect(string_io.string).to include("WARN")
      expect(string_io.string).to include("Test warning")
    end

    it "logs error messages" do
      instance.log_error("Test error")
      expect(string_io.string).to include("ERROR")
      expect(string_io.string).to include("Test error")
    end
  end
end

RSpec.describe "Inspection helpers" do
  describe Uniword::Wordprocessingml::DocumentRoot do
    let(:doc) { described_class.new }

    it "provides readable inspect output" do
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: "Test")
      para.runs << run
      doc.body.paragraphs << para
      expect(doc.inspect).to include("Uniword::Wordprocessingml::DocumentRoot")
      expect(doc.inspect).to include("@body=...")
    end
  end

  describe Uniword::Wordprocessingml::Paragraph do
    let(:para) { described_class.new }

    it "provides readable inspect output" do
      run = Uniword::Wordprocessingml::Run.new(text: "Hello World")
      para.runs << run
      expect(para.inspect).to include("Uniword::Wordprocessingml::Paragraph")
      expect(para.inspect).to include("runs=1")
      expect(para.inspect).to include("Hello World")
    end

    it "truncates long text" do
      run = Uniword::Wordprocessingml::Run.new(text: "A" * 100)
      para.runs << run
      expect(para.inspect).to include("...")
      expect(para.inspect.length).to be < 200
    end
  end

  describe Uniword::Wordprocessingml::Run do
    let(:run) { described_class.new(text: "Test text") }

    it "provides readable inspect output" do
      expect(run.inspect).to include("Uniword::Wordprocessingml::Run")
      expect(run.inspect).to include("Test text")
    end

    it "shows formatting flags" do
      run.properties = Uniword::Wordprocessingml::RunProperties.new(bold: true,
                                                                    italic: true)
      expect(run.inspect).to include("bold")
      expect(run.inspect).to include("italic")
    end

    it "truncates long text" do
      run.text = "A" * 100
      expect(run.inspect).to include("...")
      expect(run.inspect.length).to be < 150
    end
  end
end
