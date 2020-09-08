require "faraday"

class TradeGeckoWorker
  include Sidekiq::Worker

  def perform(data)
    puts "Data from the webhook: #{data}"
    url = data.dig("value", "resource_url")
    unless url.nil?
      puts "Fetch data from #{url}"
      puts ENV['TRADEGECKO_TOKEN']
      
      resp = Faraday.get(url) do |req|
        req.headers['Content-Type'] = 'application/json'
        req.headers['Accept'] = 'application/json'
        req.headers['Authorization'] = "Bearer #{ENV['TRADEGECKO_TOKEN']}"
      end
      
      tradegecko_response = JSON.parse(resp.body)
      unless tradegecko_response.nil?
        variant = tradegecko_response.dig("variant")
        message = {
          "product_name": variant.dig("product_name"),
          "retail_price": variant.dig("retail_price"),
          "sku": variant.dig("sku"),
          "stock_on_hand": variant.dig("stock_on_hand"),
          "weight": variant.dig("weight")
        }
        puts "Variant: #{variant}"
        puts "Message: #{message}"
        KafkaRepository.publish_message(message)
      end
    end
  end
end
