require "faraday"

class TradeGeckoWorker
  include Sidekiq::Worker

  def perform(data)
    puts "Data from the webhook: #{data}"
    url = data.dig("value", "resource_url")
    unless url.nil?
      puts "Fetch data from #{url}"
      puts ENV['TRADEGECKO_TOKEN']
      # resp = Faraday.get(url, { "Content-Type" => "application/json", "Accept" => "application/json", "Authorization" => "Bearer #{ENV['TRADEGECKO_TOKEN']}" })
      
      resp = Faraday.get(url) do |req|
        req.headers['Content-Type'] = 'application/json'
        req.headers['Accept'] = 'application/json'
        req.headers['Authorization'] = "Bearer #{ENV['TRADEGECKO_TOKEN']}"
      end
      
      puts "<== FULL TRADEGECKO DATA ==>"
      puts resp.body
      puts JSON.parse(resp.body)
      puts "<== FULL TRADEGECKO DATA ==>"
    end
  end
end
