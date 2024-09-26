# frozen_string_literal: true

shared_examples "school select" do
  it "shows the list of the schools and their names" do
    expect(page).to have_current_path(decidim_helsinki_smsauth.users_auth_sms_school_info_path)
    expect(page).to have_content("Login successful")

    click_button "Save and continue"
    expect(page).to have_current_path(decidim_helsinki_smsauth.users_auth_sms_school_info_path)
    within ".user-person" do
      expect(page).to have_content("There is an error in this field.")
    end
    within ".grade-info" do
      expect(page).to have_content("There is an error in this field.")
    end
  end
end
