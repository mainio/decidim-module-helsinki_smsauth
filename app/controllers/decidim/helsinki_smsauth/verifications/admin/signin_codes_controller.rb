# frozen_string_literal: true

module Decidim
  module HelsinkiSmsauth
    module Verifications
      module Admin
        class SigninCodesController < Decidim::Admin::ApplicationController
          layout "decidim/admin/users"

          def new
            @form = form(GenerateCodesForm).instance
          end

          def create
            @form = GenerateCodesForm.from_params(params.merge(user: current_user))
            ::Decidim::HelsinkiSmsauth::Verifications::Admin::GenerateAccessCodes.call(@form) do
              on(:ok) do |codes|
                generate_codes_session(codes)
                flash[:notice] = t(".success")
                redirect_to action: :view_generated_codes
              end
              on(:invalid) do
                flash[:error] = t(".error")
                render :new
              end
            end
          end

          def view_generated_codes
            @codes = generated_codes_session
            remove_generated_codes_session
            @expiration_info = set_expiration_info
          end

          def generate_csv_file
            codes = params[:codes]

            csv_data = CSV.generate(headers: true) do |csv|
              csv << [set_expiration_info]
              csv << [""]
              csv << [I18n.t(".access_codes", scope: "decidim.helsinki_smsauth.verifications.admin.signin_codes.view_generated_codes")]
              codes.each do |code|
                csv << [code]
              end
            end

            respond_to do |format|
              format.csv { send_data csv_data, file_name: "csv_codes_#{Time.current.strftime("%Y%m%d%H%M%S")}.csv" }
            end
          end

          def generate_xlsx_file
            codes = params[:codes]

            workbook = RubyXL::Workbook.new
            sheet = workbook[0]
            sheet.add_cell(0, 0, set_expiration_info)
            sheet.add_cell(2, 0, I18n.t(".access_codes", scope: "decidim.helsinki_smsauth.verifications.admin.signin_codes.view_generated_codes"))

            codes.each_with_index do |row, rowi|
              sheet.add_cell(rowi + 3, 0, row)
            end

            respond_to do |format|
              format.xlsx do
                # Generate XLSX data from the workbook and send it as a file
                send_data workbook.stream.string, type: "application/xlsx", filename: "xlsx_codes_#{Time.current.strftime("%Y%m%d%H%M%S")}.xlsx"
              end
            end
          end

          private

          def generate_codes_session(codes)
            session[:generated_codes] = codes
          end

          def generated_codes_session
            session[:generated_codes]
          end

          def remove_generated_codes_session
            session&.delete(:generated_codes)
          end

          def expiration_time
            expiration = Time.current + global_expiration_period
            l expiration, format: :short
          end

          def set_expiration_info
            t("expiration_note", scope: "decidim.helsinki_smsauth.verifications.admin.signin_codes.view_generated_codes", expiration_time:)
          end

          def global_expiration_period
            Decidim::HelsinkiSmsauth.global_expiration_period
          end
        end
      end
    end
  end
end
