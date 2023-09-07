# frozen_string_literal: true

module Decidim
  module HelsinkiSmsauth
    class SigninCodeSet < ApplicationRecord

      # TODO
      attribute :metadata, type: :hash

      belongs_to :creator, foreign_key: "decidim_user_id", class_name: "Decidim::User"
      has_many :signin_codes, foreign_key: "decidim_signin_code_set_id", class_name: "Decidim::HelsinkiSmsauth::SigninCode", dependent: :destroy

      validates :generated_code_amount, numericality: { greater_than: 0 }
      validates :used_code_amount, numericality: { greater_than_or_equal_to: 0 }

      ransacker :metadata_school do
         Arel.sql(%{("metadata"."school")::text})
      end
    end
  end
end
