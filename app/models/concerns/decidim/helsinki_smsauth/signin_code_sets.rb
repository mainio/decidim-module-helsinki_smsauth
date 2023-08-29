# frozen_string_literal: true

module Decidim
  module CreateDecidimHelsinkiSmsauth
    class SigninCodeSets < ApplicationRecord
      include Decidim::RecordEncryptor

      encrypt_attribute :metadata, type: :hash
      attribute :gererated_code_amount, type: :integer
      attribute :used_code_amount, type: :integer
      belongs_to :user, foreign_key: "decidim_user_id", class_name: "Decidim::User"
    end
  end
end
