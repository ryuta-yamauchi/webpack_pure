# frozen_string_literal: true

require "rails_helper"
RSpec.describe "Tops", type: :system do
  describe "#index" do
    it "should image name", js: true do
      visit root_path
      # expect(page).to have_content("images/ruby.jpg")
      expect(page).to have_css("img")
    end
  end
end
