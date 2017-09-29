url = case Rails.env
when "production"
  ENV["REDIS_URL"]
else
  "localhost:6379"
end

Sidekiq.configure_server do |config|
  config.redis = { url: url }
end

Sidekiq.configure_client do |config|
  config.redis = { url: url }
end
