# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Office
      # Signature line
      #
      # Generated from OOXML schema: office.yml
      # Element: <o:signatureline>
      class SignatureLine < Lutaml::Model::Serializable
          attribute :issignatureline, String
          attribute :id, String
          attribute :provid, String
          attribute :signinginstructionsset, String
          attribute :allowcomments, String
          attribute :showsigndate, String
          attribute :suggestedsigner, String
          attribute :suggestedsigner2, String
          attribute :suggestedsigneremail, String
          attribute :signinginstructions, String

          xml do
            root 'signatureline'
            namespace 'urn:schemas-microsoft-com:office:office', 'o'

            map_attribute 'true', to: :issignatureline
            map_attribute 'true', to: :id
            map_attribute 'true', to: :provid
            map_attribute 'true', to: :signinginstructionsset
            map_attribute 'true', to: :allowcomments
            map_attribute 'true', to: :showsigndate
            map_attribute 'true', to: :suggestedsigner
            map_attribute 'true', to: :suggestedsigner2
            map_attribute 'true', to: :suggestedsigneremail
            map_attribute 'true', to: :signinginstructions
          end
      end
    end
  end
end
