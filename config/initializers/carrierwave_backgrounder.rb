CarrierWave::Backgrounder.configure do |c|
   c.backend :sidekiq, queue: :carrierwave, size: 3
end
