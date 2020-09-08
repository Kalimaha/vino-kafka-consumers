namespace :kafka do
  task :consume do
    require "kafka"
    require "#{Rails.root}/app/workers/hard_worker"

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
    consumer = kafka.consumer(group_id: "#{ENV["KAFKA_PREFIX"]}test_orders_consumer_group")
    consumer.subscribe("#{ENV["KAFKA_PREFIX"]}tradegecko")

    trap("TERM") { consumer.stop }

    kafka.each_message(topic: "#{ENV["KAFKA_PREFIX"]}tradegecko", max_wait_time: 0.5) do |message|
      begin
        puts "----------"
        data = JSON.parse(message.value)
        name = data["key"] || "NAME NOT FOUND"
        count = data["value"]&.keys&.count || "COUNT NOT FOUND"
        puts "Enqueue job for #{name}"
        HardWorker.perform_async(name, count)
        puts "----------"
      rescue => e
        puts "Error parsing a message, #{e.message}"
      end
    end
  end
end
