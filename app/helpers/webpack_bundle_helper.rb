# frozen_string_literal: true

# webpackによるビルドファイル読み込み用ヘルパー
require "open-uri"
module WebpackBundleHelper
  class BundleNotFound < StandardError; end

  def asset_bundle_path(entry, **options)
    valid_entry?(entry)
    asset_path(manifest.fetch(entry), **options)
  end

  def javascript_bundle_tag(entry, **options)
    path = asset_bundle_path("#{entry}.js")

    options = {
      src: path,
      defer: true
    }.merge(options)

    # async と defer を両方指定した場合、ふつうは async が優先されるが、
    # defer しか対応してない古いブラウザの挙動を考えるのが面倒なので、両方指定は防いでおく
    options.delete(:defer) if options[:async]

    javascript_include_tag "", **options
  end

  def stylesheet_bundle_tag(entry, **options)
    path = asset_bundle_path("#{entry}.css")

    options = {
      href: path
    }.merge(options)

    stylesheet_link_tag "", **options
  end

  def image_bundle_tag(entry, **options)
    raise ArgumentError, "Extname is missing with #{entry}" unless File.extname(entry).present?

    image_tag asset_bundle_path(entry), **options
  end

  private

    def manifest
      @manifest ||= JSON.parse(manifest_json_file)
    end

    def manifest_json_file
      return OpenURI.open_uri("http://railswebpack:3035/assets/manifest.json").read if Rails.env.development?

      File.read("public/assets/manifest.json")
    end

    def valid_entry?(entry)
      return true if manifest.key?(entry)

      raise BundleNotFound, "Could not find bundle with name #{entry}"
    end
end
