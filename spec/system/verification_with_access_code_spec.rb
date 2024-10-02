# frozen_string_literal: true

require "spec_helper"

describe "verification with access code", type: :system do
  include_context "with helsinki_smsauth_id authorization"
  include_context "with single access code"

  let(:access_code) { "ABCDE12345" }
  let(:incorrect_code) { "FalseCode" }

  before do
    switch_to_host(organization.host)
  end

  describe "verification" do
    before do
      sign_in user, scope: :user
      visit decidim.account_path
      click_on "Authorization"
      click_on "Subscribe"
      click_on "Log in with a code given by your teacher or youth worker"
    end

    it "behaves like verifiable access code" do
      expect(page).to have_content "Verify your account with a code given by your teacher or youth worker"
      expect(page).to have_link("Return to text message login", href: "/helsinki_smsauth_id/authorizations/new")
      expect(page).to have_button("Verify your account")
    end

    context "with invalid access code" do
      it "does not authorize the user" do
        # empty form submission
        fill_in_with
        expect(page).to have_content "There is an error in this field."

        fill_in_with(incorrect_code)

        within_flash_messages do
          expect(page).to have_content "Failed to authorize. Please try again."
        end
      end
    end

    context "with correct access code" do
      let(:school) { signin_code_set.metadata["school"] }
      let(:grade) { signin_code_set.metadata["grade"] }

      it "authorizes and redirects the user" do
        fill_in_with(access_code)
        authorization = Decidim::Authorization.find_by(decidim_user_id: user.id)
        expect(authorization).to be_present
        expect(authorization).to be_granted
        expect(authorization.metadata["grade"]).to eq(grade)
        expect(authorization.metadata["school"]).to eq(school)
        expect(page).to have_current_path("/authorizations")
        within_flash_messages do
          expect(page).to have_content("Congratulations. You have been successfully verified.")
        end
      end
    end
  end

  private

  def fill_in_with(code = nil)
    fill_in("sms_verification[access_code]", with: code) if code

    click_button "Verify your account"
  end
end
