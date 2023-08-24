# frozen_string_literal: true

module Decidim
  module HelsinkiSmsauth
    module SystemTestHelpers
      def visit_helsinki_smsauth
        visit decidim_helsinki_smsauth.users_auth_sms_path
      end

      def visit_verification
        visit decidim_helsinki_smsauth.users_auth_sms_verification_path
      end
    end
  end
end

RSpec.configure do |config|
  config.include Decidim::HelsinkiSmsauth::SystemTestHelpers, type: :system
end
