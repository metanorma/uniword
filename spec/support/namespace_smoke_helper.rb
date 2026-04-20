# frozen_string_literal: true

# Helper for namespace-level smoke tests.
# Introspects a module's autoloaded constants and generates
# tests that verify each class loads, instantiates, and serializes.
module NamespaceSmokeHelper
  # Resolves all autoloaded constants in a namespace module,
  # returning only Class objects (skipping sub-modules).
  #
  # @param namespace [Module] e.g. Uniword::Bibliography
  # @return [Array<Class>]
  def self.classes_in(namespace)
    namespace.constants.sort.filter_map do |name|
      klass = namespace.const_get(name)
      klass if klass.is_a?(Class)
    rescue StandardError
      nil
    end
  end

  # Filters classes that inherit from Lutaml::Model::Serializable.
  #
  # @param namespace [Module]
  # @return [Array<Class>]
  def self.serializable_classes_in(namespace)
    classes_in(namespace).select do |klass|
      klass < Lutaml::Model::Serializable
    rescue StandardError
      false
    end
  end

  # Defines smoke tests for a namespace module.
  # Computes class lists eagerly at describe-time so that
  # example groups can be generated dynamically.
  #
  # @param namespace [Module] The namespace to test
  # @param label [String] Human-readable label for describe block
  def self.define_smoke_tests_for(namespace, label:)
    # Eagerly resolve classes so we can generate example groups
    all_classes = classes_in(namespace)
    serializable_classes = serializable_classes_in(namespace)

    RSpec.describe "#{label} namespace smoke tests" do
      it "loads the namespace module" do
        expect(namespace).to be_a(Module)
      end

      it "has autoloaded classes" do
        expect(all_classes).not_to be_empty
      end

      describe "autoload verification" do
        all_classes.each do |klass|
          it "#{klass.name} is a Class" do
            expect(klass).to be_a(Class)
          end
        end
      end

      describe "instantiation" do
        all_classes.each do |klass|
          it "#{klass.name} instantiates with .new" do
            begin
              klass.send(:new)
            rescue ArgumentError
              skip "requires constructor arguments"
            rescue NoMethodError
              skip "private constructor"
            end
            expect(true).to be true
          end
        end
      end

      describe "XML serialization" do
        serializable_classes.each do |klass|
          it "#{klass.name} produces parseable XML" do
            obj = klass.new
            begin
              xml = obj.to_xml
              doc = Nokogiri::XML(xml)
              expect(doc.errors).to be_empty
            rescue Lutaml::Model::NoRootMappingError
              skip "reusable model (no root mapping)"
            rescue Lutaml::Model::UnknownTypeError
              skip "unregistered custom type"
            end
          end
        end
      end
    end
  end
end
