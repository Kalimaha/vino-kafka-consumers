namespace :kafka do
  task :consume_tradegecko do
    require "kafka"
    require "#{Rails.root}/app/workers/trade_gecko_worker"

    tmp_ca_file = Tempfile.new("ca_certs")
    tmp_ca_file.write(ENV.fetch("KAFKA_TRUSTED_CERT"))
    tmp_ca_file.close
    
    kafka = Kafka.new(
      seed_brokers: ENV.fetch("KAFKA_URL"),
      ssl_ca_cert_file_path: tmp_ca_file.path,
      ssl_client_cert: ENV.fetch("KAFKA_CLIENT_CERT"),
      ssl_client_cert_key: ENV.fetch("KAFKA_CLIENT_CERT_KEY"),
      ssl_verify_hostname: false,
    )
    
    tradegecko_consumer = kafka.consumer(group_id: "#{ENV["KAFKA_PREFIX"]}tradegecko_consumer_group")
    tradegecko_consumer.subscribe("#{ENV["KAFKA_PREFIX"]}tradegecko")

    trap("TERM") { tradegecko_consumer.stop }

    kafka.each_message(topic: "#{ENV["KAFKA_PREFIX"]}tradegecko", max_wait_time: 0.5) do |message|
      puts "Message: #{message}"
      data = JSON.parse(message.value)
      puts "Data: #{data}"
      TradeGeckoWorker.perform_async(data)
    end
  end
end
