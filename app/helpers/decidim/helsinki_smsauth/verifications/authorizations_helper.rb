# frozen_string_literal: true

module Decidim
  module HelsinkiSmsauth
    module Verifications
      module AuthorizationsHelper
        include Decidim::HelsinkiSmsauth::OmniauthHelper
        include Decidim::HelsinkiSmsauth::RegistrationHelper
      end
    end
  end
end
