# frozen_string_literal: true

require "spec_helper"

describe "PhoneLogin" do
  let(:organization) { create(:organization) }
  let(:auth_metadata) { { school: "0004", grade: 1, phone_number: "+3584551122334" } }

  include_context "with telia gateway"

  before do
    switch_to_host(organization.host)
    visit_helsinki_smsauth
  end

  it_behaves_like "authenticate with phone process"
  describe "log-in with SMS" do
    let(:phone) { 4_551_122_334 }

    context "when user exists" do
      let!(:user) { create(:user, organization:, phone_number: "+3584551122334") }

      context "when authorization with school info exists" do
        let!(:authorization) do
          create(
            :authorization,
            :granted,
            name: "helsinki_smsauth_id",
            user:,
            metadata: auth_metadata
          )
        end

        it "authenticate and redirects the user" do
          verify_phone
          expect(page).to have_current_path("/")
        end
      end

      context "when authorization does not exist" do
        before do
          verify_phone
        end

        it_behaves_like "school select"
        it "authenticate and redirects the user" do
          within ".user-person" do
            select "Etu-Töölön lukio", from: "School"
          end

          fill_in "Grade", with: 1
          click_on "Save and continue"
          expect(page).to have_current_path decidim.root_path
          user = Decidim::User.last
          expect(user.phone_number).to eq("+3584551122334")
          authorization = Decidim::Authorization.last
          expect(authorization.metadata).to eq(
            {
              "school" => "00845",
              "grade" => 1,
              "phone_number" => "+3584551122334"
            }
          )
          expect(authorization.granted?).to be true
        end
      end
    end
  end

  private

  def verify_phone
    fill_in "Phone number", with: phone
    click_on "Send code"
    code = page.find_by_id("hint").text
    fill_in "Login code", with: code
    within ".new_sms_verification" do
      click_on "Log in"
    end
  end
end
