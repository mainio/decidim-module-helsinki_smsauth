# frozen_string_literal: true

module Decidim
  module HelsinkiSmsauth
    module Verifications
      module Admin
        class GenerateAccessCodes < Decidim::Command
          def initialize(form)
            @form = form
          end

          def call
            broadcast(:invalid) unless @form.valid?

            transaction do
              generate_code_set!
              generate_codes!
            end
            broadcast(:invalid) if @codes.empty?

            broadcast(:ok, @codes)
          end

          private

          attr_reader :form

          def generate_code_set!
            params = {
              generated_code_amount: form.generate_code_amount,
              metadata: { school: form.school, grade: form.grade },
              creator: form.user
            }
            @signin_code_set = Decidim.traceability.create!(
              ::Decidim::HelsinkiSmsauth::SigninCodeSet,
              form.user,
              params
            )
          end

          def generate_codes!
            @codes = [].tap do |array|
              form.generate_code_amount.times do
                array << create_access_code
              end
            end
          end

          def create_access_code
            code_instance = ::Decidim::HelsinkiSmsauth::SigninCode.new(signin_code_set: @signin_code_set)
            code_hash = code_instance.generate!
            code_instance.code_hash = encrypt_hash(code_hash)
            code_instance.save!
            code_hash
          end

          def encrypt_hash(code)
            digest = "#{code}-#{Rails.application.secrets.secret_key_base}"
            Digest::MD5.hexdigest(digest)
          end
        end
      end
    end
  end
end
