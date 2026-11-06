# frozen_string_literal: true

module Decidim
  module HelsinkiSmsauth
    module Admin
      class Permissions < Decidim::DefaultPermissions
        def permissions
          return permission_action unless permission_action.scope == :admin
          return permission_action unless user&.admin?

          allow! if permission_action.subject == :signin_codes && permission_action.action == :create

          permission_action
        end
      end
    end
  end
end
