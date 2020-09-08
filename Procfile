web:                  bundle exec puma -C config/puma.rb
worker:               bundle exec sidekiq -e production -C config/sidekiq.yml
tradegecko_consumer:  bundle exec rake kafka:consume_tradegecko
bigcommerce_consumer: bundle exec rake kafka:consume_bigcommerce