# frozen_string_literal:  true

module Decidim
  module HelsinkiSmsauth
    class SchoolMetadataForm < Decidim::Form
      include ::Decidim::FormFactory

      attribute :school_code, String
      attribute :grade, Integer
      attribute :phone_number, String
      attribute :current_locale, String
      attribute :organization, Decidim::Organization

      validates :school_code, inclusion: { in: :valid_school_codes }
      validates :grade, numericality: { greater_than: 0 }

      def valid_school_codes
        SchoolMetadata.school_options.map { |school_data| school_data[1] }
      end
    end
  end
end
