# frozen_string_literal: true

module Decidim
  module HelsinkiSmsauth
    class SigninCodeSession < ApplicationRecord
      belongs_to :user, -> { respond_to?(:entire_collection) ? entire_collection : self }, foreign_key: "decidim_user_id", class_name: "Decidim::User"
      belongs_to :signin_code_set, foreign_key: "decidim_signin_code_set_id", class_name: "::Decidim::HelsinkiSmsauth::SigninCodeSet"
    end
  end
end
