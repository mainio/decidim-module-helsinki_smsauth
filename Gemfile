# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

# Inside the development app, the relative require has to be one level up, as
# the Gemfile is copied to the development_app folder (almost) as is.
base_path = ""
base_path = "../" if File.basename(__dir__) == "development_app"
require_relative "#{base_path}lib/decidim/helsinki_smsauth/version"

DECIDIM_VERSION = Decidim::HelsinkiSmsauth.decidim_version

gem "decidim", DECIDIM_VERSION
gem "decidim-helsinki_smsauth", path: "."

gem "bootsnap", "~> 1.4"
gem "puma", ">= 5.6.2"

gem "faker", "~> 2.14"

group :development, :test do
  gem "byebug", "~> 11.0", platform: :mri
  gem "decidim-dev", DECIDIM_VERSION
  # gem "decidim-sms-twilio", github: "mainio/decidim-sms-telia", branch: "main"
  gem "decidim-sms-telia", path: "../decidim-sms-telia"
end

group :development do
  gem "letter_opener_web", "~> 2.0"
  gem "listen", "~> 3.1"
  gem "rubocop-faker"
  gem "spring", "~> 2.0"
  gem "spring-watcher-listen", "~> 2.0"
  gem "web-console", "~> 4.2"
end
