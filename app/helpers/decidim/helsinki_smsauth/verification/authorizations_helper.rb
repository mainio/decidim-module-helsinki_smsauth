# frozen_string_literal: true

module Decidim
  module HelsinkiSmsauth
    module Verification
      module AuthorizationsHelper
        include Decidim::HelsinkiSmsauth::OmniauthHelper
        include Decidim::HelsinkiSmsauth::RegistrationHelper
      end
    end
  end
end
