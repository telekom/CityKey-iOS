source "https://rubygems.org"

gem 'fastlane'
gem "dotenv"
gem "xcode-install"
gem "cocoapods"

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
