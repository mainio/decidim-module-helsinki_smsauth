# frozen_string_literal: true

require "spec_helper"

describe "authentication with phone number", type: :system do
  let(:organization) { create(:organization) }
  # let(:auth_metadata) { { "school" => "0004", "grade" => 1, "phone_number" => "+3584551122334" } }
  let(:auth_metadata) { { school: "0004", grade: 1, phone_number: "+3584551122334" } }

  include_context "with telia gateway"

  before do
    switch_to_host(organization.host)
    visit_helsinki_smsauth
  end

  it_behaves_like "phone verification process"
  describe "log-in with SMS" do
    let(:phone) { 4_551_122_334 }

    context "when user exists" do
      let!(:user) { create(:user, organization: organization, phone_number: "+3584551122334") }

      context "when authorization with school info exists" do
        let!(:authorization) do
          create(
            :authorization,
            :granted,
            name: "helsinki_smsauth_id",
            user: user,
            metadata: auth_metadata
          )
        end

        it "authenticate and redirects the user" do
          verify_phone
          expect(page).to have_current_path("/authorizations")
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
          click_signup
          expect(page).to have_current_path decidim_verifications.authorizations_path
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

  def click_signup
    click_button "Sign up"
    within "#sign-up-newsletter-modal" do
      click_button "Keep unchecked"
    end
  end

  def verify_phone
    fill_in "Phone number", with: phone
    click_button "Send code via SMS"
    code = page.find("#hint").text
    fill_in "Verification code", with: code
    click_button "Verify"
  end
end
