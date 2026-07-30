# frozen_string_literal: true

base_path = File.expand_path("..", __dir__)

Decidim::Shakapacker.register_path("#{base_path}/app/packs")
Decidim::Shakapacker.register_entrypoints(
  decidim_helsinki_smsauth: "#{base_path}/app/packs/entrypoints/decidim_helsinki_smsauth.js"
)
Decidim::Shakapacker.register_stylesheet_import("stylesheets/decidim/helsinki_smsauth/helsinki_smsauth")
