# frozen_string_literal: true

require "spec_helper"

describe "verification code generation", type: :system do
  include_context "with helsinki_smsauth_id authorization"

  let!(:admin) { create(:user, :admin, :confirmed, organization: organization) }

  it_behaves_like "filterable login code"
  describe "login code generation" do
    before do
      switch_to_host(organization.host)
      login_as admin, scope: :user
      visit "admin/users"
    end

    it "renders authorizations views" do
      within "#admin-sidebar-menu-settings" do
        expect(page).to have_link("Login via text message")
      end

      click_link("Login via text message")
      expect(page).to have_current_path("/admin/helsinki_smsauth_id/")
      expect(page).to have_content("Alternative login codes")

      click_link "Create codes"
      expect(page).to have_current_path("/admin/helsinki_smsauth_id/signin_codes/new")
      expect(page).to have_content("Create codes")

      click_button "Create"
      expect(page).to have_content("is not included in the list")
    end
  end
end
