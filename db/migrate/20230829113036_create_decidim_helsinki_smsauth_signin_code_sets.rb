# frozen_string_literal: true

class CreateDecidimHelsinkiSmsauthSigninCodeSets < ActiveRecord::Migration[6.1]
  def change
    create_table :decidim_helsinki_smsauth_signin_code_sets do |t|
      t.jsonb :metadata
      t.integer :generated_code_amount
      t.integer :used_code_amount
      t.references :decidim_user, null: false, index: { name: "index_helsinki_smsauth_code_sets_on_decidim_user" }

      t.datetime :created_at
    end
  end
end
