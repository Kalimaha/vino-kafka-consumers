require "faraday"

class BigCommerceWorker
  include Sidekiq::Worker

  def perform(data)
    url = "https://api.bigcommerce.com/stores/6zw8cyfm80/v3/catalog/products"
    resp = Faraday.post(url) do |req|
      req.headers['Content-Type'] = 'application/json'
      req.headers['Accept'] = 'application/json'
      req.headers['X-Auth-Token'] = ENV['BIGCOMMERCE_PASSWORD']
      req.headers['X-Auth-Client'] = ENV['BIGCOMMERCE_USERNAME']
      req.body = {
        name: data.dig("value", "product_name"),
        price: data.dig("value", "retail_price"),
        categories: ["24"],
        weight: data.dig("value", "weight_value") || 100.0,
        type: "physical",
        images: [
          {
            image_url: "https://media.vinomofo.com/uploads/70afb99f75346d06a3a6e921cb4154f7?1597284193",
            is_thumbnail: true
          }
        ],
        inventory_level: data.dig("value", "stock_on_hand")
      }.to_json
    end
  end
end
