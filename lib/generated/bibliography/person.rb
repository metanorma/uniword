# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Bibliography
      # Individual person with first and last names
      #
      # Generated from OOXML schema: bibliography.yml
      # Element: <b:person>
      class Person < Lutaml::Model::Serializable
          attribute :first, :string
          attribute :middle, :string
          attribute :last, :string

          xml do
            root 'person'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/bibliography', 'b'
            mixed_content

            map_element 'First', to: :first, render_nil: false
            map_element 'Middle', to: :middle, render_nil: false
            map_element 'Last', to: :last
          end
      end
    end
  end
end
