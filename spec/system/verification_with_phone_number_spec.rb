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
    expect(page).to have_content("Sign in with Sms")
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
      let!(:another_user) { create(:user, :confirmed, organization: organization, phone_number: "+3584567890") }
      let(:auth_metadata) { { school: "0004", grade: 1, phone_number: "+3584567890" } }
      let!(:authorization) do
        create(
          :authorization,
          :granted,
          name: "helsinki_smsauth_id",
          user: another_user,
          metadata: auth_metadata,
          unique_id: "36622e90d8c073ac33cfa896610632a9"
        )
      end

      it "gives error" do
        # visit current_path
        expect(page).to have_content("Authorize your account")
        fill_in "Phone number", with: 4_567_890
        click_button "Send code via SMS"

        expect(page).to have_content "There was a problem with your request"
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
        fill_in "Phone number", with: 4_567_891
        click_button "Send code via SMS"
      end

      it "generates the authorization process" do
        expect(page).to have_current_path("/helsinki_smsauth_id/authorizations/edit")
        within_flash_messages do
          expect(page).to have_content "Thanks! We've sent an SMS to your phone."
        end

        expect(page).to have_link("Resend code", href: "/helsinki_smsauth_id/authorizations/resend_code")
        expect(page).to have_link("Restart verification", href: "/helsinki_smsauth_id/authorizations")
        fill_in "Verification code", with: "wrong code"
        click_button "Verify"
        expect(page).to have_content("Verification failed. Please try again.")
      end

      it "Verifies accont when everything is ok" do
        code = page.find("#hint").text
        fill_in "Verification code", with: code
        authorization = Decidim::Authorization.find_by(decidim_user_id: user.id)
        click_button "Verify"

        expect(authorization.metadata["phone_number"]).to eq("+3584567891")
        expect(authorization).not_to be_granted
        expect(page).to have_current_path("/helsinki_smsauth_id/authorizations/school_info")
        visit "/authorizations"
        expect(page).to have_css('svg[aria-label="Pending verification"]')
      end

      context "when adding school info" do
        before do
          code = page.find("#hint").text
          fill_in "Verification code", with: code
          click_button "Verify"
        end

        it "renders the school info correctly" do
          expect(page).to have_current_path("/helsinki_smsauth_id/authorizations/school_info")
          expect(page).to have_content("You have successfully verified your account. Now you need to enter your school information")

          click_button "Submit"
          expect(page).to have_current_path("/helsinki_smsauth_id/authorizations/school_info")
          within ".user-person" do
            expect(page).to have_content("There's an error in this field.")
          end
          within ".grade-info" do
            expect(page).to have_content("There's an error in this field.")
          end
        end

        it "grant authorization after adding school info" do
          within ".user-person" do
            select "Etu-Töölön lukio", from: "School"
          end
          fill_in "Grade", with: 1
          expect(Decidim::Authorization.find_by(decidim_user_id: user.id)).not_to be_granted
          click_button "Submit"
          authorization = Decidim::Authorization.find_by(decidim_user_id: user.id)
          expect(authorization).to be_granted
          expect(authorization.metadata["grade"]).to eq(1)
          expect(authorization.metadata["school"]).to be_present
        end
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
