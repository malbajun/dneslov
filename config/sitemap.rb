#!/usr/bin/env ruby

require 'yaml'
require 'rails'
require 'dotenv/load'
require 'sitemap_generator'

# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "https://dneslov.org"

ink = ENV["INDEXNOW_KEY"]

engines = {
   yandex: 'http://webmaster.yandex.com/site/map.xml?host=%s',
   index_now: "https://api.indexnow.org/indexnow?url=https://dneslov.org/sitemap.xml&key=#{ink}",
   bing: "https://www.bing.com/indexnow?url=https://dneslov.org/sitemap.xml&key=#{ink}",
   naver: "https://searchadvisor.naver.com/indexnow?url=https://dneslov.org/sitemap.xml&key=#{ink}",
   seznam: "https://search.seznam.cz/indexnow?url=https://dneslov.org/sitemap.xml&key=#{ink}",
   yep: "https://indexnow.yep.com/indexnow?url=https://dneslov.org/sitemap.xml&key=#{ink}"
}

SitemapGenerator::Sitemap.search_engines =
   SitemapGenerator::Utilities.reverse_merge(SitemapGenerator::Sitemap.search_engines, engines)

# The directory to write sitemaps to locally
if Rails.env.production? or Rails.env.staging?
   SitemapGenerator::Sitemap.public_path = 'public/'
else
   SitemapGenerator::Sitemap.verbose = true
   SitemapGenerator::Sitemap.public_path = 'public/'
end

# Set this to a directory/path if you don't want to upload to the root of your `sitemaps_host`
#SitemapGenerator::Sitemap.sitemaps_path = 'sitemaps/'
SitemapGenerator::Sitemap.create do
   add('/', priority: 1, changefreq: 'daily')
   add('/about', priority: 1, changefreq: 'monthly')

   Picture.find_each do |picture|
      add(picture_path(picture), lastmod: memory.updated_at, changefreq: 'annual')
   end

   Memory.find_each do |memory|
      next unless memory.slug

      add(slug_path(memory.slug.text), lastmod: memory.updated_at, changefreq: 'monthly')
      add(slugged_gallery_path(memory.slug.text), lastmod: memory.updated_at, changefreq: 'monthly')

      memory.events.each do |event|
         add(slug_event_path(memory.slug.text, event), lastmod: memory.updated_at, changefreq: 'monthly')
         add(event_gallery_path(memory.slug.text, event), lastmod: memory.updated_at, changefreq: 'monthly')

         event.calendaries.each do |calendary|
            add(cslug_event_path(calendary.slug.text, memory.slug.text, event), lastmod: memory.updated_at, changefreq: 'monthly')
         end
      end

      memory.calendaries.each do |cal|
         add(slug_path(cal.slug.text), priority: 0.7, changefreq: 'daily')
         add(cslug_path(cal.slug.text, memory.slug.text), lastmod: memory.updated_at, changefreq: 'monthly')
      end
   end
end
