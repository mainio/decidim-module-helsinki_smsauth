# frozen_string_literal: true

require "spec_helper"

describe "verificqation code generation", type: :system do
  include_context "with helsinki_smsauth_id authorization"

  let!(:admin) { create(:user, :admin, :confirmed, organization: organization) }

  it_behaves_like "filterable login code"
  xdescribe "login code generation" do
    before do
      switch_to_host(organization.host)
      login_as admin, scope: :user
      visit "admin/users"
    end

    it "renders authorizations" do
      within ".secondary-nav" do
        expect(page).to have_link("Login via text message")
      end

      click_link("Login via text message")
      expect(page).to have_current_path("admin/helsinki_smsauth_id/")
      expect(page).to have_content("Alternative login codes")
    end
  end
end
