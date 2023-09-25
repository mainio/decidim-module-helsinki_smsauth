# frozen_string_literal: true

shared_examples "authenticate with phone process" do
  include_context "with telia gateway"

  describe "authentication process" do
    it "does the authentication process" do
      expect(page).to have_content("Problems?")
      expect(page).to have_link("Log in with a code given by your teacher", href: "/users/auth/sms/access_code")
      fill_in "Phone number", with: "45887874"
      click_button "Send code"
      within_flash_messages do
        expect(page).to have_content(/The code has been sent to/)
      end
      expect(page).to have_content("Log in via text message")
      click_link("Resend the code")
      within_flash_messages do
        expect(page).to have_content("Please wait at least 1 minute to resend the code.")
      end
      allow(Time).to receive(:current).and_return(2.minutes.from_now)
      click_link("Resend the code")
      expect(page).to have_content(/The code has been sent to/)
      fill_in "Login code", with: "000000"
      click_button "Log in"
      within_flash_messages do
        expect(page).to have_content("Failed to verify the phone number. Please try again and check that you have entered the login code correctly.")
      end
      code = page.find("#hint").text
      fill_in "Login code", with: code
      click_button "Log in"
      expect(page).not_to have_current_path decidim_helsinki_smsauth.users_auth_sms_edit_path
      within_flash_messages do
        expect(page).not_to have_content("Failed to verify the phone number. Please try again and check that you have entered the login code correctly.")
      end
    end
  end
end
