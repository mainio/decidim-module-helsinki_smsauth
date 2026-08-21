# frozen_string_literal: true

require "spec_helper"

describe "CodeGenerationVerification" do
  include_context "with helsinki_smsauth_id authorization"

  let!(:admin) { create(:user, :admin, :confirmed, organization:) }

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

      click_on "Login via text message"
      expect(page).to have_current_path("/en/admin/helsinki_smsauth_id/")
      expect(page).to have_content("Alternative login codes")

      click_on "Create codes"
      expect(page).to have_current_path("/en/admin/helsinki_smsauth_id/signin_codes/new")
      expect(page).to have_content("Create codes")

      click_on "Create"
      expect(page).to have_content("is not included in the list")
    end

    describe "code creation form" do
      before do
        click_on "Login via text message"
        click_on "Create codes"
      end

      it "shows validation errors when fields are empty" do
        click_on "Create"
        expect(page).to have_content("is not included in the list")
      end

      it "shows validation error for missing code amount" do
        select "Alppilan lukio", from: "signin_codes_school"
        fill_in "signin_codes_grade", with: 3
        click_on "Create"
        expect(page).to have_content("is not a number")
      end

      it "shows validation error when code amount exceeds maximum" do
        select "Alppilan lukio", from: "signin_codes_school"
        fill_in "signin_codes_grade", with: 3
        fill_in "signin_codes_generate_code_amount", with: 101
        click_on "Create"
        expect(page).to have_content("must be less than or equal to 100")
      end

      it "generates codes successfully" do
        select "Alppilan lukio", from: "signin_codes_school"
        fill_in "signin_codes_grade", with: 3
        fill_in "signin_codes_generate_code_amount", with: 5
        click_on "Create"
        expect(page).to have_content("Creating the login codes was successful.")
        expect(page).to have_content("Download CSV")
        expect(page).to have_content("Download XLSX")
      end
    end

    describe "viewing generated codes" do
      before do
        click_on "Login via text message"
        click_on "Create codes"
        select "Alppilan lukio", from: "signin_codes_school"
        fill_in "signin_codes_grade", with: 2
        fill_in "signin_codes_generate_code_amount", with: 3
        click_on "Create"
      end

      it "displays the generated codes table" do
        expect(page).to have_content("Creating the login codes was successful.")
        expect(page).to have_css("table.table-list tbody tr", count: 3)
      end

      it "shows expiration info" do
        expect(page).to have_content("expir")
      end

      it "provides CSV download link" do
        expect(page).to have_link("Download CSV")
      end

      it "provides XLSX download link" do
        expect(page).to have_link("Download XLSX")
      end
    end

    describe "index page with existing codes" do
      let!(:code_set) { create(:signin_code_set, creator: admin, generated_code_amount: 5) }

      before do
        click_on "Login via text message"
      end

      it "shows existing code sets in the table" do
        expect(page).to have_css("table.stack.table-list tbody tr", minimum: 1)
      end

      it "displays creator name" do
        expect(page).to have_content(admin.name)
      end

      it "displays the school name" do
        school_code = code_set.metadata["school"]
        school = Decidim::HelsinkiSmsauth::SchoolMetadata.school_name(school_code)
        expect(page).to have_content(school) if school
      end

      it "displays code counts" do
        within "table.stack.table-list tbody tr:first-child" do
          expect(page).to have_content("5")
          expect(page).to have_content("0")
        end
      end
    end

    describe "search functionality" do
      let!(:code_sets) { create_list(:signin_code_set, 3, creator: admin, generated_code_amount: 2) }

      before do
        click_on "Login via text message"
      end

      it "filters by creator name" do
        fill_in "Creator or name of the school", with: admin.name[0..3]
        find('button[aria-label="Search"]').click
        expect(page).to have_css("table.stack.table-list tbody tr", minimum: 1)
      end

      it "shows no results for non-matching search" do
        fill_in "Creator or name of the school", with: "nonexistentpersonxyz"
        find('button[aria-label="Search"]').click
        expect(page).to have_no_css("table.stack.table-list tbody tr")
      end
    end
  end
end
