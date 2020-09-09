require "kafka"
require "securerandom"

class KafkaRepository
  class << self
    def publish_message(message_body)
      topic   = "#{ENV["KAFKA_PREFIX"]}bigcommerce"
      puts "PUBLISH TO #{topic}"
      message = { "key": SecureRandom.uuid, "value": message_body }

      puts "TOPIC: #{topic}"
      puts "MESSAGE: #{message}"
      
      kafka_client.deliver_message(message.to_json, topic: topic)
    end

    private

    def kafka_client
      tmp_ca_file = Tempfile.new("ca_certs")
      tmp_ca_file.write(ENV.fetch("KAFKA_TRUSTED_CERT"))
      tmp_ca_file.close
    
      puts "ssl_ca_cert_file_path: #{tmp_ca_file.path}"
    
      @_kafka ||= Kafka.new(
        seed_brokers: ENV.fetch("KAFKA_URL"),
        ssl_ca_cert_file_path: tmp_ca_file.path,
        ssl_client_cert: ENV.fetch("KAFKA_CLIENT_CERT"),
        ssl_client_cert_key: ENV.fetch("KAFKA_CLIENT_CERT_KEY"),
        ssl_verify_hostname: false,
      )
    end
  end
end
