# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Chart
      # Error bars
      #
      # Generated from OOXML schema: chart.yml
      # Element: <c:errBars>
      class ErrorBars < Lutaml::Model::Serializable
          attribute :err_dir, ErrorDirection
          attribute :err_bar_type, ErrorBarType
          attribute :err_val_type, :string
          attribute :no_end_cap, :string
          attribute :plus, :string
          attribute :minus, :string
          attribute :val, :string
          attribute :sp_pr, :string

          xml do
            element 'errBars'
            namespace Uniword::Ooxml::Namespaces::Chart
            mixed_content

            map_element 'errDir', to: :err_dir, render_nil: false
            map_element 'errBarType', to: :err_bar_type
            map_element 'errValType', to: :err_val_type
            map_element 'noEndCap', to: :no_end_cap, render_nil: false
            map_element 'plus', to: :plus, render_nil: false
            map_element 'minus', to: :minus, render_nil: false
            map_element 'val', to: :val, render_nil: false
            map_element 'spPr', to: :sp_pr, render_nil: false
          end
      end
    end
end
