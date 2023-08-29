# frozen_string_literal: true

module Decidim
  module HelsinkiSmsauth
    class SigninCodeSetsForm < Form
      mimic :signin_codes

      attribute :gererated_code_amount, Integer
      attribute :used_code_amount, Integer
      attribute :user, String

      validates :gererated_code_amount, numericality: { greater_than: 0 }
      validates :used_code_amount, numericality: { greater_than_or_equal_to: 0 }
      validates :user, presence: true
    end
  end
end
