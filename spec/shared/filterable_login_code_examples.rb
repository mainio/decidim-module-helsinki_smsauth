# frozen_string_literal: true

shared_examples "filterable login code" do
  let!(:creators) { create_list(:user, 2, :confirmed, :admin, organization: organization) }
  let!(:unused_codes) do
    10.times do
      create_list(:signin_code_set, 1, generated_code_amount: code_amount, creator: creators[0])
    end
  end

  let!(:used_codes) do
    5.times do
      create_list(:signin_code_set, 1, :with_used_codes, generated_code_amount: code_amount, creator: creators[1])
    end
  end

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
    visit "admin/helsinki_smsauth_id"
  end

  it "filters based on creator name" do
    fill_in "q[creator_name_cont]", with: creators[0].name[0..3]
    click_button("Search")
    table = find("table.stack.table-list")
    rows = table.find("tbody").all("tr")
    expect(rows.count).to eq(10)
    rows.each do |row|
      creator = row.find("td:nth-child(2)")
      expect(creator.text).to eq(creators[0].name)
    end
  end

  it "filters based on school name" do
    table = find("table.stack.table-list")
    first_school = table.find("tbody").all("tr")[0].find("td:nth-child(3)").text
    fill_in "q[creator_name_cont]", with: first_school
    click_button("Search")
    rows = table.find("tbody").all("tr")
    rows.each do |row|
      school = row.find("td:nth-child(3)")
      expect(school.text).to eq(first_school)
    end
  end

  it "filters based on used codes" do
    click_link "Filter"
    find("a", text: "Includes used codes").hover
    click_link "Yes"
    table = find("table.stack.table-list")
    rows = table.find("tbody").all("tr")
    expect(rows.count).to eq(10)
    rows.each do |row|
      used_codes = row.find("td:nth-child(6)")
      expect(used_codes.text).to eq("0")
    end

    click_link "Filter"
    find("a", text: "Includes used codes").hover
    click_link "No"
    rows = table.find("tbody").all("tr")
    expect(rows.count).to eq(5)
    rows.each do |row|
      used_codes = row.find("td:nth-child(6)")
      expect(used_codes.text).not_to eq("0")
    end
  end

  private

  def code_amount
    rand(1..6)
  end

  def existing_school
    unused_codes.first.metadata
  end
end
