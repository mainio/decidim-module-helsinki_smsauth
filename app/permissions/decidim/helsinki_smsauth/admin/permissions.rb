# frozen_string_literal: true

module Decidim
  module HelsinkiSmsauth
    module Admin
      class Permissions < Decidim::DefaultPermissions
        def permissions
          return permission_action if permission_action.scope != :admin

          case permission_action.subject
          when :signin_code_sets
            case permission_action.action
            when :create, :read
              allow!
            end
          end

          permission_action
        end
      end
    end
  end
end
