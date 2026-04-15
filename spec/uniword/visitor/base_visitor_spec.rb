# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Visitor::BaseVisitor do
  let(:visitor) { described_class.new }

  describe "#visit_document" do
    it "provides a no-op default implementation" do
      document = Uniword::Wordprocessingml::DocumentRoot.new
      expect { visitor.visit_document(document) }.not_to raise_error
    end

    it "accepts a document parameter" do
      expect(visitor.method(:visit_document).arity).to eq(1)
    end
  end

  describe "#visit_paragraph" do
    it "provides a no-op default implementation" do
      paragraph = Uniword::Wordprocessingml::Paragraph.new
      expect { visitor.visit_paragraph(paragraph) }.not_to raise_error
    end

    it "accepts a paragraph parameter" do
      expect(visitor.method(:visit_paragraph).arity).to eq(1)
    end
  end

  describe "#visit_table" do
    it "provides a no-op default implementation" do
      table = Uniword::Wordprocessingml::Table.new
      expect { visitor.visit_table(table) }.not_to raise_error
    end

    it "accepts a table parameter" do
      expect(visitor.method(:visit_table).arity).to eq(1)
    end
  end

  describe "#visit_table_row" do
    it "provides a no-op default implementation" do
      row = Uniword::Wordprocessingml::TableRow.new
      expect { visitor.visit_table_row(row) }.not_to raise_error
    end

    it "accepts a table row parameter" do
      expect(visitor.method(:visit_table_row).arity).to eq(1)
    end
  end

  describe "#visit_table_cell" do
    it "provides a no-op default implementation" do
      cell = Uniword::Wordprocessingml::TableCell.new
      expect { visitor.visit_table_cell(cell) }.not_to raise_error
    end

    it "accepts a table cell parameter" do
      expect(visitor.method(:visit_table_cell).arity).to eq(1)
    end
  end

  describe "#visit_run" do
    it "provides a no-op default implementation" do
      run = Uniword::Wordprocessingml::Run.new(text: "test")
      expect { visitor.visit_run(run) }.not_to raise_error
    end

    it "accepts a run parameter" do
      expect(visitor.method(:visit_run).arity).to eq(1)
    end
  end

  describe "#visit_image" do
    it "provides a no-op default implementation" do
      image = Uniword::Image.new(relationship_id: "rId1")
      expect { visitor.visit_image(image) }.not_to raise_error
    end

    it "accepts an image parameter" do
      expect(visitor.method(:visit_image).arity).to eq(1)
    end
  end

  describe "inheritance" do
    it "can be subclassed to create custom visitors" do
      custom_visitor = Class.new(described_class) do
        attr_reader :visited_elements

        def initialize
          super
          @visited_elements = []
        end

        def visit_paragraph(_paragraph)
          @visited_elements << :paragraph
        end

        def visit_run(_run)
          @visited_elements << :run
        end
      end

      visitor_instance = custom_visitor.new
      visitor_instance.visit_paragraph(Uniword::Wordprocessingml::Paragraph.new)
      visitor_instance.visit_run(Uniword::Wordprocessingml::Run.new(text: "test"))

      expect(visitor_instance.visited_elements).to eq(%i[paragraph run])
    end
  end

  describe "visitor pattern support" do
    it "works with element accept methods" do
      paragraph = Uniword::Wordprocessingml::Paragraph.new
      expect { paragraph.accept(visitor) }.not_to raise_error
    end

    it "allows elements to dispatch to appropriate visit methods" do
      custom_visitor = Class.new(described_class) do
        attr_accessor :last_visited

        def visit_paragraph(_paragraph)
          self.last_visited = :paragraph
        end

        def visit_run(_run)
          self.last_visited = :run
        end
      end

      visitor_instance = custom_visitor.new
      paragraph = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: "test")

      paragraph.accept(visitor_instance)
      expect(visitor_instance.last_visited).to eq(:paragraph)

      run.accept(visitor_instance)
      expect(visitor_instance.last_visited).to eq(:run)
    end
  end
end
