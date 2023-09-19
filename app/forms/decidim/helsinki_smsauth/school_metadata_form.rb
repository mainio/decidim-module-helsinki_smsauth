# frozen_string_literal:  true

module Decidim
  module HelsinkiSmsauth
    class SchoolMetadataForm < Decidim::Form
      include ::Decidim::FormFactory

      attribute :school, String
      attribute :grade, Integer
      attribute :phone_number, String
      attribute :current_locale, String
      attribute :organization, Decidim::Organization

      validates :school, :grade, presence: true

      validates :school, inclusion: { in: :valid_schools }
      validates :grade, numericality: { greater_than: 0 }

      def valid_schools
        SchoolMetadata.school_options.map { |data| data[1] }
      end
    end
  end
end
