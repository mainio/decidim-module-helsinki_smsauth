# frozen_string_literal: true

module Decidim
  module HelsinkiSmsauth
    class OmniauthForm < Form
      mimic :sms_sign_in

      attribute :phone_number, Integer

      validates :phone_number, numericality: { greater_than: 0 }, presence: true
    end
  end
end
