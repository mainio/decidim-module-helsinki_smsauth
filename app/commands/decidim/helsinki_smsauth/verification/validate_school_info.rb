# frozen_string_literal: true

module Decidim
  module HelsinkiSmsauth
    module Verification
      class ValidateSchoolInfo < Decidim::Command
        def initialize(form, handler)
          @form = form
          @handler = handler
        end

        def call
          broadcast(:invalid) unless @form.valid?
          update_handler!
        end

        private

        def update_handler!
          @handler.metadata["grade"] = @form.grade
          @handler.metadata["school"] = @form.school
          @handler.grant!
          broadcast(:ok)
        end
      end
    end
  end
end
