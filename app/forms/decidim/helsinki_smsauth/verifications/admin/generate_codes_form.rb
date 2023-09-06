# frozen_string_literal: true

module Decidim
  module HelsinkiSmsauth
    module Verifications
      module Admin
        class GenerateCodesForm < Form
          mimic :signin_codes

          attribute :generate_code_amount, Integer
          attribute :school, String
          attribute :grade, Integer
          attribute :user, String

          validates :generate_code_amount, numericality: { greater_than: 0 }
          validates :generate_code_amount, numericality: { less_than: 100 }
          validates :school, inclusion: { in: :valid_schools }
          validates :user, presence: true

          def valid_schools
            Decidim::HelsinkiSmsauth::SchoolMetadata.school_options.map { |data| data[1] }
          end
        end
      end
    end
  end
end
