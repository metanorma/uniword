# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    class StructuredDocumentTag
      # Date format for Date SDT
      class DateFormat < Lutaml::Model::Serializable
        attribute :value, :string

        xml do
          element 'dateFormat'
          namespace Ooxml::Namespaces::WordProcessingML
          map_attribute 'val', to: :value, render_nil: false
        end
      end

      # Language ID for Date SDT
      class Lid < Lutaml::Model::Serializable
        attribute :value, :string

        xml do
          element 'lid'
          namespace Ooxml::Namespaces::WordProcessingML
          map_attribute 'val', to: :value, render_nil: false
        end
      end

      # Store Mapped Data As for Date SDT
      class StoreMappedDataAs < Lutaml::Model::Serializable
        attribute :value, :string

        xml do
          element 'storeMappedDataAs'
          namespace Ooxml::Namespaces::WordProcessingML
          map_attribute 'val', to: :value, render_nil: false
        end
      end

      # Calendar type for Date SDT
      class Calendar < Lutaml::Model::Serializable
        attribute :value, :string

        xml do
          element 'calendar'
          namespace Ooxml::Namespaces::WordProcessingML
          map_attribute 'val', to: :value, render_nil: false
        end
      end

      # Date control in SDT properties
      # Reference XML: <w:date w:fullDate="2012-06-20T00:00:00Z"><w:dateFormat w:val="M/d/yy"/><w:lid w:val="en-US"/><w:storeMappedDataAs w:val="dateTime"/><w:calendar w:val="gregorian"/></w:date>
      class Date < Lutaml::Model::Serializable
        attribute :full_date, :string
        attribute :date_format, DateFormat
        attribute :lid, Lid
        attribute :store_mapped_data_as, StoreMappedDataAs
        attribute :calendar, Calendar

        xml do
          element 'date'
          namespace Ooxml::Namespaces::WordProcessingML
          mixed_content

          map_attribute 'fullDate', to: :full_date, render_nil: false
          map_element 'dateFormat', to: :date_format, render_nil: false
          map_element 'lid', to: :lid, render_nil: false
          map_element 'storeMappedDataAs', to: :store_mapped_data_as, render_nil: false
          map_element 'calendar', to: :calendar, render_nil: false
        end
      end
    end
  end
end
