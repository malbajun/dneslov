# https://slickplan.com/blog/rails-sitemap
xml.instruct!
xml.sitemapindex xmlns: 'https://www.sitemaps.org/schemas/sitemap/0.9' do
   (1..count).each do |i|
      xml.sitemap do
         xml.loc "#{folder}/sitemap#{i}.xml.gz"
         xml.lastmod Time.now.utc.strftime('%Y-%m-%dT%H:%M:%S%:z')
         xml.changefreq "monthly"
         xml.priority 0.8
      end
   end
end
