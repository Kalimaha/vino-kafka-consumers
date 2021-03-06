require "faraday"

class TradeGeckoWorker
  include Sidekiq::Worker

  def perform(data)
    url = data.dig("value", "resource_url")
    unless url.nil?
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
          "weight": variant.dig("weight"),
          "weight_value": variant.dig("weight_value")
        }
        KafkaRepository.publish_message(message)
      end
    end
  end
end
