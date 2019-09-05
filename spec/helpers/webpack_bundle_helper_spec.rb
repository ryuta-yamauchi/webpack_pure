
require "rails_helper"
require "webmock/rspec"

RSpec.describe WebpackBundleHelper, type: :helper do
  before(:all) do
    WebMock.enable!
  end

  after(:all) do
    WebMock.disable!
  end

  before(:each) do
    manifest_json_str = File.read(Rails.root.join("spec", "fixtures", "manifest.json").to_s)
    allow(File).to receive(:read).with("public/assets/manifest.json").and_return(manifest_json_str)
  end

  describe "#asset_bundle_path" do
    context "extname is js entry name" do
      subject { asset_bundle_path("application.js") }

      it "should return file name" do
        is_expected.to eq("/assets/js/application-824dbdf73f00e24d25b3.js")
      end
    end

    context "extname is css entry name" do
      subject { asset_bundle_path("application.css") }

      it "should return file name" do
        is_expected.to eq("/assets/stylesheets/application-824dbdf73f00e24d25b3.css")
      end
    end

    context "extname is image entry name" do
      subject { asset_bundle_path("images/ruby.jpg") }

      it "should return file name" do
        is_expected.to eq("/assets/images/ruby-7c507c9018e4b6f1ec0d69adf64145de.jpg")
      end
    end

    context "extname is not entry name" do
      subject { -> { asset_bundle_path("error_test") } }

      it "BundleNotFound Error" do
        is_expected.to raise_error(WebpackBundleHelper::BundleNotFound, "Could not find bundle with name error_test")
      end
    end
  end

  describe "#javascript_bundle_tag" do
    context "extname is js entry name" do
      subject { javascript_bundle_tag("application") }

      it "should render <script> tag" do
        is_expected.to eq(%Q(<script src="/assets/js/application-824dbdf73f00e24d25b3.js" defer="defer"></script>))
      end
    end

    context "extname is js entry name with async" do
      subject { javascript_bundle_tag("application", async: true) }

      it "should render <script> tag" do
        is_expected.to eq(%Q(<script src="/assets/js/application-824dbdf73f00e24d25b3.js" async="async"></script>))
      end
    end

    context "should is js not entry name" do
      subject { -> { javascript_bundle_tag("error_test") } }

      it "should BundleNotFound Error" do
        is_expected.to raise_error(WebpackBundleHelper::BundleNotFound, "Could not find bundle with name error_test.js")
      end
    end
  end

  describe "#stylesheet_bundle_tag" do
    context "extname is css entry name" do
      subject { stylesheet_bundle_tag("application") }

      it "should render <link> tag" do
        is_expected.to eq(%Q(<link rel="stylesheet" media="screen" href="/assets/stylesheets/application-824dbdf73f00e24d25b3.css" />))
      end
    end

    context "extname is css entry name" do
      subject { -> { stylesheet_bundle_tag("error_test") } }

      it "should BundleNotFound Error" do
        is_expected.to raise_error(WebpackBundleHelper::BundleNotFound, "Could not find bundle with name error_test.css")
      end
    end
  end

  describe "#image_bundle_tag" do
    context "filename is images/ruby.jpg entry name" do
      subject { image_bundle_tag("images/ruby.jpg") }

      it "should render <img> tag" do
        is_expected.to eq(%Q(<img src="/assets/images/ruby-7c507c9018e4b6f1ec0d69adf64145de.jpg" />))
      end
    end

    context "filename is not found entry name" do
      subject { -> { image_bundle_tag("error_test.png") } }

      it "should BundleNotFound Error" do
        is_expected.to raise_error(WebpackBundleHelper::BundleNotFound, "Could not find bundle with name error_test.png")
      end
    end

    context "without extname" do
      subject { -> { image_bundle_tag("error_test") } }

      it "should ArgumentError" do
        is_expected.to raise_error(ArgumentError)
      end
    end
  end
end
