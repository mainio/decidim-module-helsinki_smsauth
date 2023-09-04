# frozen_string_literal: true

module Decidim
  module HelsinkiSmsauth
    module Verification
      class ValidateSchoolInfo < Decidim::Command
        def initialize(form)
          @form = form
        end

        def call
          broadcast(:invalid) unless @form.valid?
          broadcast(:ok)
        end
      end
    end
  end
end
