# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Properties
    # Table conditional formatting flags
    # Represents visual appearance settings for table rows/columns
    # Reference XML:
    # <w:tblLook w:val="04A0" w:firstRow="1" w:lastRow="0"
    #            w:firstColumn="1" w:lastColumn="0"
    #            w:noHBand="0" w:noVBand="1"/>
    class TableLook < Lutaml::Model::Serializable
      # Pattern 0: ATTRIBUTES FIRST
      attribute :val, :string          # Hex value representing flags
      attribute :first_row, :integer   # Apply first row formatting (0/1)
      attribute :last_row, :integer    # Apply last row formatting (0/1)
      attribute :first_column, :integer # Apply first column formatting (0/1)
      attribute :last_column, :integer  # Apply last column formatting (0/1)
      attribute :no_h_band, :integer    # No horizontal banding (0/1)
      attribute :no_v_band, :integer    # No vertical banding (0/1)

      xml do
        element "tblLook"
        namespace Ooxml::Namespaces::WordProcessingML
        map_attribute 'val', to: :val, render_nil: false
        map_attribute 'firstRow', to: :first_row, render_nil: false
        map_attribute 'lastRow', to: :last_row, render_nil: false
        map_attribute 'firstColumn', to: :first_column, render_nil: false
        map_attribute 'lastColumn', to: :last_column, render_nil: false
        map_attribute 'noHBand', to: :no_h_band, render_nil: false
        map_attribute 'noVBand', to: :no_v_band, render_nil: false
      end
    end
  end
end
