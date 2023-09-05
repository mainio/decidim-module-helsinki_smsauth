# frozen_string_literal: true

module Decidim
  module HelsinkiSmsauth
    class SigninCodeSet < ApplicationRecord
      include Decidim::RecordEncryptor
      include Decidim::Searchable

      # TODO
      encrypt_attribute :metadata, type: :hash

      belongs_to :creator, foreign_key: "decidim_user_id", class_name: "Decidim::User"
      has_many :signin_codes, foreign_key: "decidim_signin_code_set_id", class_name: "Decidim::HelsinkiSmsauth::SigninCode"

      searchable_fields(
        {
          decidim_user_id: :decidim_user_id,
          A: :title
        }
      )
      validates :generated_code_amount, numericality: { greater_than: 0 }
      validates :used_code_amount, numericality: { greater_than_or_equal_to: 0 }
    end
  end
end
