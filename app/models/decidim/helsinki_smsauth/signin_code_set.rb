# frozen_string_literal: true

module Decidim
  module HelsinkiSmsauth
    class SigninCodeSet < ApplicationRecord
      include Decidim::FilterableResource

      attribute :metadata, type: :hash

      belongs_to :creator, -> { respond_to?(:entire_collection) ? entire_collection : self }, foreign_key: "decidim_user_id", class_name: "Decidim::User"
      has_many :signin_codes, foreign_key: "decidim_signin_code_set_id", class_name: "Decidim::HelsinkiSmsauth::SigninCode", dependent: :destroy

      validates :generated_code_amount, numericality: { greater_than: 0 }
      validates :used_code_amount, numericality: { greater_than_or_equal_to: 0 }

      ransacker :has_unused_codes do
        Arel.sql(%((#{table_name}.used_code_amount < #{table_name}.generated_code_amount)::boolean))
      end

      def self.ransackable_attributes(_auth_object = nil)
        %w(created_at decidim_user_id generated_code_amount has_unused_codes id medata used_code_amount)
      end

      def self.ransackable_associations(_auth_object = nil)
        %w(creator signin_codes)
      end
    end
  end
end
