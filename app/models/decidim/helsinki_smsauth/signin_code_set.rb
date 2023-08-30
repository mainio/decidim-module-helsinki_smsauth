# frozen_string_literal: true

module Decidim
  module HelsinkiSmsauth
    class SigninCodeSet < ApplicationRecord
      include Decidim::RecordEncryptor

      # TODO
      encrypt_attribute :metadata, type: :hash

      belongs_to :creator, foreign_key: "decidim_user_id", class_name: "Decidim::User"
      has_many :signin_codes, foreign_key: "decidim_signin_code_set_id", class_name: "Decidim::HelsinkiSmsauth::SigninCode"

      validates :generated_code_amount, numericality: { greater_than: 0 }
      validates :used_code_amount, numericality: { greater_than_or_equal_to: 0 }
    end
  end
end
