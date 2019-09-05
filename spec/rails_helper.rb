
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)

abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end
RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  config.include FactoryBot::Syntax::Methods

  config.after(:suite) do
    Kernel.system("rm -f #{Rails.root.join("spec", "webpack_build")}")
  end

  config.before(:each) do |example|
    if example.metadata[:type] == :system || example.metadata[:run_webpack]
      # type: :system 時の初回だけ yarn build:dev を走らせる
      # 静的な画像URLなどを返すために :run_webpack でも build:dev しなければならないケースがある
      if !ENV["NO_WEBPACK"] && !File.exist?(Rails.root.join("spec", "webpack_build").to_s)
        Kernel.system("yarn", "build:dev")
        Kernel.system("touch #{Rails.root.join("spec", "webpack_build").to_s}")
      end
    end

    if example.metadata[:type] == :system
      if example.metadata[:js]
        driven_by :selenium, using: :headless_chrome, screen_size: [1280, 800], options: {
          args: [
            "headless",
            "disable-gpu",
            "no-sandbox",
            { "lang" => "ja-JP" }
          ]
        }
      else
        driven_by :rack_test
      end
    end
  end
end
