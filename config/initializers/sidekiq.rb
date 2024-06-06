require 'sidekiq/worker_killer'

Sidekiq.default_job_options = { 'backtrace' => true }

Sidekiq.configure_server do |config|
   config.redis = {
      url: "#{ENV["REDIS_URL"]}/4",
      ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
   }

   config.server_middleware do |chain|
      chain.add Sidekiq::WorkerKiller, max_rss: 512
   end

   config.average_scheduled_poll_interval = 2
   # TODO sentry
   # config.error_handlers << proc {|ex,ctx_hash| MyErrorService.notify(ex, ctx_hash) }
end

Sidekiq.configure_client do |config|
   config.redis = {
      url: "#{ENV["REDIS_URL"]}/4",
      ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
   }
end
