# frozen_string_literal: true

base_path = File.expand_path("..", __dir__)

Decidim::Webpacker.register_path("#{base_path}/app/packs")
Decidim::Webpacker.register_entrypoints(
  decidim_helsinki_smsauth: "#{base_path}/app/packs/entrypoints/decidim_helsinki_smsauth.js",
  decidim_newsletter_checkbox: "#{base_path}/app/packs/entrypoints/decidim_newsletter_checkbox.js",
  decidim_backup_confirmation: "#{base_path}/app/packs/entrypoints/decidim_backup_confirmation.js"
)
Decidim::Webpacker.register_stylesheet_import("stylesheets/decidim/helsinki_smsauth/helsinki_smsauth")
