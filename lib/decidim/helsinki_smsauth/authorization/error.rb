# frozen_string_literal: true

module Decidim
  module HelsinkiSmsauth
    module Authorization
      class Error < StandardError; end

      class AuthorizationBoundToOtherUserError < Error; end
    end
  end
end
