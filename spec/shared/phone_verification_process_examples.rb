# frozen_string_literal: true

shared_examples "phone verification process" do
  include_context "with telia gateway"

  describe "authentication process" do
    it "does the authentication process" do
      expect(page).to have_content("Do you have problem with SMS authentication?")
      expect(page).to have_link("Log in with the code given by your teacher", href: "/users/auth/sms/access_code")
      fill_in "Phone number", with: "45887874"
      click_button "Send code via SMS"
      within_flash_messages do
        expect(page).to have_content(/Verification code sent to/)
      end
      expect(page).to have_content("Enter verification code")
      click_link("Resend code")
      within_flash_messages do
        expect(page).to have_content("Please wait at least 1 minute to resend the code.")
      end
      allow(Time).to receive(:current).and_return(2.minutes.from_now)
      click_link("Resend code")
      expect(page).to have_content(/Verification code resent to/)
      fill_in "Verification code", with: "000000"
      click_button "Verify"
      within_flash_messages do
        expect(page).to have_content("Verification failed. Please try again.")
      end
      code = page.find("#hint").text
      fill_in "Verification code", with: code
      click_button "Verify"
      expect(page).not_to have_current_path decidim_helsinki_smsauth.users_auth_sms_edit_path
      within_flash_messages do
        expect(page).not_to have_content("Verification failed. Please try again.")
      end
    end
  end
end
