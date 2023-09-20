# frozen_string_literal: true

require "decidim/core/test/factories"

FactoryBot.define do
  factory :signin_code_set, class: "Decidim::HelsinkiSmsauth::SigninCodeSet" do
    creator { create(:user, :confirmed, :admin, organization: organization) }
    generated_code_amount { 1 }
    metadata do
      {
        school: Faker::Name.name,
        grade: Faker::Number.between(from: 1, to: 6)
      }
    end

    after(:create) do |signin_code_set, evaluator|
      create_list(:signin_code, evaluator.generated_code_amount, signin_code_set: signin_code_set)
    end
  end

  factory :signin_code, class: "Decidim::HelsinkiSmsauth::SigninCode" do
    signin_code_set { create(signin_code_set) }
  end
end
