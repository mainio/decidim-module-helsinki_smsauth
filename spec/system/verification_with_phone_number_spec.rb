# frozen_string_literal: true

require "spec_helper"

describe "verification with phone number", type: :system do
  let!(:organization) { create(:organization, omniauth_settings: omniauth_settings, available_authorizations: available_authorizations) }
  let!(:user) { create(:user, :confirmed, organization: organization) }
  let(:available_authorizations) { ["helsinki_smsauth_id"] }
  let(:omniauth_settings) do
    {
      "omniauth_settings_sms_enabled" => true,
      "omniauth_settings_sms_icon" => ""
    }
  end

  include_context "with telia gateway"

  before do
    switch_to_host(organization.host)
  end

  it "Adds the sms login method to authorization methods" do
    visit "/users/sign_in"
    expect(page).to have_content("Sign in with SMS")
    within ".register__separator" do
      expect(page).to have_content "Or"
    end
  end

  describe "Account section" do
    before do
      sign_in user, scope: :user
      visit decidim.account_path
    end

    it "shows the available authorizations" do
      within "#user-settings-tabs" do
        expect(page).to have_css("a", text: "Authorizations")
      end
      click_link "Authorization"
      expect(page).to have_content "Participant settings - Authorizations"
      within ".card--list__item" do
        expect(page).to have_css("svg.icon--lock-unlocked", count: 1)
      end
    end
  end

  describe "verification" do
    before do
      sign_in user, scope: :user
      visit decidim.account_path
      click_link "Authorization"
      find(".card--list__item").click
    end

    context "when authorization belongs to someone else" do
      let!(:another_user) { create(:user, :confirmed, organization: organization, phone_number: "+35845123456789") }
      let(:auth_metadata) { { school: "0004", grade: 1, phone_number: "+3584551122334" } }
      let!(:authorization) do
        create(
          :authorization,
          :granted,
          name: "helsinki_smsauth_id",
          user: another_user,
          metadata: auth_metadata
        )
      end

      it "gives error" do
        expect(page).to have_content("Authorize your account")
        fill_in "Phone number", with: 4_567_890
        click_button "Send code via SMS"
        within_flash_messages do
          expect(page).to have_content "There was a problem with your request"
        end
        expect(page).to have_content "A participant is already authorized with the same data. An administrator will contact you to verify your details."
      end
    end

    it "shows phone number authorization" do
      expect(page).to have_content("Authorize your account")
      expect(page).to have_link("Authorize yourself with the code given by your teacher", href: "/helsinki_smsauth_id/authorizations/access_code")
      click_button "Send code via SMS"
      expect(page).to have_content "There's an error in this field."
    end

    context "with valid phone number" do
      before do
        fill_in "Phone number", with: 4_567_890
        click_button "Send code via SMS"
      end

      it "generates the authorization process" do
        expect(page).to have_current_path("/helsinki_smsauth_id/authorizations/edit")
        within_flash_messages do
          expect(page).to have_content "Thanks! We've sent an SMS to your phone."
          expect(page).to have_link("Resend code", href: "/helsinki_smsauth_id/authorizations/resend_code")
          expect(page).to have_link("Restart verifiction", href: "/helsinki_smsauth_id/authorizations")
          fill_in "Verification code", with: "wrong code"
          expect(page).to have_content("Verification failed. Please try again.× ")
        end
      end

      it "Verifies accont when everything is ok" do
        code = page.find("#hint").text
        fill_in "Verification code", with: code
        expext do
          click_button "Verify"
        end.to change(Decidim::Authoriztion, :count).by(1)
        expect(page).to have_current_path
      end
    end
  end

  context "when verified" do
    before do
      user.update!(phone_number: "+358457788123")
      sign_in user, scope: :user
      visit decidim.account_path
    end

    it "shows masked phone number" do
      expect(page).to have_field("Your phone number", disabled: true, with: "+358*****123")
    end
  end
end
