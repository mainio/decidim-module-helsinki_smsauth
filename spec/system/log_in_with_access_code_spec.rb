# frozen_string_literal: true

require "spec_helper"

describe "AccessCodeLogin" do
  let!(:organization) { create(:organization) }
  let(:access_code) { "ABCDE12345" }
  let(:incorrect_code) { "FalseCode" }

  include_context "with single access code"
  before do
    switch_to_host(organization.host)
    visit_helsinki_smsauth
    click_on "Log in with a code given by your teacher"
  end

  it "does not authenticate when incorrect code" do
    fill_in "sms_verification[access_code]", with: incorrect_code
    within ".new_sms_verification" do
      click_on "Log in"
    end
    within_flash_messages do
      expect(page).to have_content("Failed to verify the access code. Make sure that you have entered the correct code and try again.")
    end
    expect(page).to have_current_path("/users/auth/sms/access_code_validation")
  end

  context "when correct code" do
    let!(:creator) { create(:user, :confirmed, :admin, organization:) }
    let!(:signin_code_set) { create(:signin_code_set, creator:) }
    let!(:signin_code) { create(:signin_code, code: access_code, signin_code_set:) }

    it "creates users and signs in with correct code" do
      expect(signin_code_set.used_code_amount).to eq(0)

      fill_in "sms_verification[access_code]", with: access_code
      within ".new_sms_verification" do
        click_on "Log in"
      end
      expect(page).to have_content("Login successful.")
      signin_code_set.reload
      expect(signin_code_set.used_code_amount).to eq(1)

      authorization = Decidim::Authorization.last
      expect(authorization.metadata["school"]).to eq(signin_code_set.metadata["school"])
      expect(authorization.metadata["grade"]).to eq(signin_code_set.metadata["grade"])
      within_flash_messages do
        expect(page).to have_content "Login successful"
      end
    end
  end
end
