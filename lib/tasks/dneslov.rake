namespace :dneslov do
   namespace :memory do
      desc "Converts memory council list to council memoes for specific calendary"
      task :council_proceed, [:c, :a] => :environment do |t, args|
         MemoryCouncilListToEmbeddedMemoesService.new(calendaries: args[:c].split(":"), fake: ((args[:a] || "false") == "false")).convert
      end

      desc "Merge memories if one have short name and they matches descriptions"
      task :merge, [:description, :description_from] => :environment do |t, args|
         MemoryService.new(description: args[:description], description_from: args[:description_from]).merge
      end
   end

   namespace :image do
      desc "Synchronizes images from a source folde to target restructurizing the target image tree"
      task :proceed, [:source, :targets] => :environment do |t, args|
         ImageSyncService.new(source: args[:source], targets: args[:targets].split(":")).sync
      end

      desc "Syncronize image folders to upserver with rsync"
      task :rsync, [:source, :targets] => :environment do |t, args|
         args[:targets].split(":").each do |target|
            %x{rsync -r --exclude='lost+found' #{args[:source]}/ #{target}/ 2>&1}
         end
      end

      desc "Load resources with newly appeared scheme uris to DB"
      task :resourcesify, [:storage] => :environment do |t, args|
         ImageSyncService.new(storage: args[:storage]).import
      end

      desc "Load resources and converts them into obejcts: image_url, etc"
      task :load, [:asset_path] => :environment do |t, args|
         ImageSyncService.new(asset_path: args[:asset_path]).load
      end

      desc "Clean lastest resources and related to them links"
      task :clean do |t|
         t = (Resource.last&.created_at || Time.at(10**10)) - 5.minutes
         Resource.where("created_at >= ?", t).destroy_all
      end

      desc "MrProperize source folder"
      task :mrproper, [:source] => :environment do |t, args|
         ImageSyncService.new(source: args[:source]).cleanup
      end
   end

   namespace :calendary do
      desc "Copy calendary's memoes from sources to a target calendary defined by slug or name"
      task :copy, [:sources, :target]  => :environment do |t, args|
         CalendaryCopy.new(target: args[:target], sources: args[:sources].split(":")).do
      end
   end

   desc "Upload photoes"
   task :upload, [:path, :short_name, :event_id, :kind, :url] => :environment do |t, args|
      Tasks.upload_images(args[:path], args[:short_name], args[:event_id], args[:kind], args[:url])

      true
   end

   namespace :music do
      desc "render znamen xml"
      task :render_xml, [:source, :target] => :environment do |t, args|
         Znamenar.new(source: args[:source], target: args[:target]).render_xml
      end
   end

   namespace :language do
      desc "fix language letters"
      task :name_letter_fix, [:lang, :alph] => :environment do |t, args|
         Languager.new(language: args[:lang], alphabeth: args[:alph]).name_letter_fix
      end
   end

   namespace :event do
      desc "merge similar events via memo"
      task :merge, [:slugs] => :environment do |t, args|
         Eventer.new(slugs: args[:slugs]&.split(/,/)).merge
      end
   end
end
