# frozen_string_literal: true

require "spec_helper"

describe "verification with phone number", type: :system do
  include_context "with helsinki_smsauth_id authorization"
  include_context "with telia gateway"

  before do
    switch_to_host(organization.host)
  end

  it "Adds the sms login method to authorization methods" do
    visit "/users/sign_in"
    expect(page).to have_link('Sms', href: '/users/auth/sms', title: 'Log in with Sms')
    within ".login__omniauth-separator" do
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
          unique_id: Digest::MD5.hexdigest("FI-4567890-#{Rails.application.secrets.secret_key_base}")
        )
      end

      it "gives error" do
        # visit current_path
        expect(page).to have_content("Verify your phone number")
        fill_in "Phone number", with: 4_567_890
        click_button "Send code"

        expect(page).to have_content "There was a problem with your request"
        expect(page).to have_content "A participant is already authorized with the same data. An administrator will contact you to verify your details."
      end
    end

    it "shows phone number authorization" do
      expect(page).to have_content("Verify your phone number")
      expect(page).to have_link("Log in with a code given by your teacher or youth worker", href: "/helsinki_smsauth_id/authorizations/access_code")
      click_button "Send code"
      expect(page).to have_content "There is an error in this field."
    end

    context "with valid phone number" do
      before do
        fill_in "Phone number", with: 4_567_891
        click_button "Send code"
      end

      it "generates the authorization process" do
        expect(page).to have_current_path("/helsinki_smsauth_id/authorizations/edit")
        within_flash_messages do
          expect(page).to have_content "Thanks! We've sent an SMS to your phone."
        end

        expect(page).to have_link("Resend the code", href: "/helsinki_smsauth_id/authorizations/resend_code")
        expect(page).to have_link("Re-enter the phone number", href: "/helsinki_smsauth_id/authorizations")
        fill_in "Login code", with: "wrong code"
        click_button "Continue"
        expect(page).to have_content("Failed to authorize. Please try again.")
      end

      it "Verifies accont when everything is ok" do
        code = page.find("#hint").text
        fill_in "Login code", with: code
        authorization = Decidim::Authorization.find_by(decidim_user_id: user.id)
        click_button "Continue"

        expect(authorization.metadata["phone_number"]).to eq("+3584567891")
        expect(authorization).not_to be_granted
        expect(page).to have_current_path("/helsinki_smsauth_id/authorizations/school_info")
        visit "/authorizations"
        expect(page).to have_css('svg[aria-label="Pending verification"]')
      end

      context "when adding school info" do
        before do
          code = page.find("#hint").text
          fill_in "Login code", with: code
          click_button "Continue"
        end

        it "renders the school info correctly" do
          expect(page).to have_current_path("/helsinki_smsauth_id/authorizations/school_info")
          expect(page).to have_content("Text message verification successful. Please enter few more details and you are done.")

          click_button "Save and continue"
          expect(page).to have_current_path("/helsinki_smsauth_id/authorizations/school_info")
          within ".user-person" do
            expect(page).to have_content("There is an error in this field.")
          end
          within ".grade-info" do
            expect(page).to have_content("There is an error in this field.")
          end
        end

        it "grant authorization after adding school info" do
          within ".user-person" do
            select "Etu-Töölön lukio", from: "School"
          end
          fill_in "Grade", with: 1

          expect(Decidim::Authorization.find_by(decidim_user_id: user.id)).not_to be_granted
          click_button "Save and continue"
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
      expect(page).to have_field("Phone number", disabled: true, with: "+358*****123")
    end
  end
end
