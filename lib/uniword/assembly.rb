# frozen_string_literal: true

module Uniword
  module Assembly
    autoload :AssemblyManifest, "#{__dir__}/assembly/assembly_manifest"
    autoload :ComponentRegistry, "#{__dir__}/assembly/component_registry"
    autoload :CrossReferenceResolver, "#{__dir__}/assembly/cross_reference_resolver"
    autoload :DocumentAssembler, "#{__dir__}/assembly/document_assembler"
    autoload :TocGenerator, "#{__dir__}/assembly/toc_generator"
    autoload :VariableSubstitutor, "#{__dir__}/assembly/variable_substitutor"
  end
end
