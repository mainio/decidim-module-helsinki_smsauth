# frozen_string_literal: true

shared_examples "school select" do
  it "shows the list of the schools and their names" do
    expect(page).to have_current_path(decidim_helsinki_smsauth.users_auth_sms_school_info_path)
    expect(page).to have_content("Great! you are now authenticated to vote. We need some more information about you, which you can enter in the fields shown below. After entering the information, you can vote.")

    click_signup
    expect(page).to have_current_path(decidim_helsinki_smsauth.users_auth_sms_school_info_path)
    within ".user-person" do
      expect(page).to have_content("There's an error in this field.")
    end
    within ".grade-info" do
      expect(page).to have_content("There's an error in this field.")
    end
  end

  private

  def click_signup
    click_button "Sign up"
    within "#sign-up-newsletter-modal" do
      click_button "Keep unchecked"
    end
  end
end
