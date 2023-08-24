# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/helsinki_smsauth/version"

Gem::Specification.new do |s|
  s.version = Decidim::HelsinkiSmsauth.version
  s.authors = ["Sina Eftekhar"]
  s.email = ["sina.eftekhar@mainiotech.fi"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/mainio/decidim-module-ptp"
  s.required_ruby_version = ">= 3.0"

  s.name = "decidim-helsinki_smsauth"
  s.summary = "A decidim smsauth module for helsinki"
  s.description = "SMS based authentication implementation."

  s.files = Dir["{app,config,lib}/**/*", "LICENSE-AGPLv3.txt", "Rakefile", "README.md"]

  s.add_dependency "decidim-core", Decidim::HelsinkiSmsauth.decidim_version
  s.metadata["rubygems_mfa_required"] = "true"
end
