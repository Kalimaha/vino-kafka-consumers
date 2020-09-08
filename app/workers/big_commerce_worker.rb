require "faraday"

class BigCommerceWorker
  include Sidekiq::Worker

  def perform(data)
    puts "<== DATA FROM KAFKA ==>"
    puts data
    puts "<== DATA FROM KAFKA ==>"

    url = "https://api.bigcommerce.com/stores/6zw8cyfm80/v3/catalog/products"
    resp = Faraday.post(url) do |req|
      req.headers['Content-Type'] = 'application/json'
      req.headers['Accept'] = 'application/json'
      req.headers['X-Auth-Token'] = ENV['BIGCOMMERCE_PASSWORD']
      req.headers['X-Auth-Client'] = ENV['BIGCOMMERCE_USERNAME']
      req.body = {
        name: data.dig("value", "product_name"),
        price: data.dig("value", "retail_price"),
        categories: ["18"],
        weight: data.dig("value", "weight"),
        type: "physical",
        inventory_level: data.dig("value", "stock_on_hand")
      }.to_json
    end
    puts "<== BigCommerce SAYS ==>"
    puts resp.body
    puts "<== BigCommerce SAYS ==>"

    # url = data.dig("value", "resource_url")
    # unless url.nil?
    #   resp = Faraday.get(url) do |req|
    #     req.headers['Content-Type'] = 'application/json'
    #     req.headers['Accept'] = 'application/json'
    #     req.headers['Authorization'] = "Bearer #{ENV['TRADEGECKO_TOKEN']}"
    #   end
    #   tradegecko_response = JSON.parse(resp.body)
    #   unless tradegecko_response.nil?
    #     variant = tradegecko_response.dig("variant")
    #     message = {
    #       "product_name": variant.dig("product_name"),
    #       "retail_price": variant.dig("retail_price"),
    #       "sku": variant.dig("sku"),
    #       "stock_on_hand": variant.dig("stock_on_hand"),
    #       "weight": variant.dig("weight")
    #     }
    #     KafkaRepository.publish_message(message)
    #   end
    # end
  end
end
