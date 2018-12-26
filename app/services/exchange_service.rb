require 'rest-client'
require 'json'

class ExchangeService
  def initialize(source_currency, target_currency, amount)
    @source_currency = source_currency
    @target_currency = target_currency
    @amount = amount.to_f
  end

 
  def perform
    begin
      if @source_currency == 'BTC' || @target_currency == 'BTC'
        if @source_currency == 'BTC'
          bitcoin_api_url = Rails.application.credentials[Rails.env.to_sym][:bitcoin_api_url]
          url = "#{bitcoin_api_url}#{@target_currency}.json"
          res = RestClient.get url
          value = JSON.parse(res.body)['bpi'][@target_currency]['rate_float']

          @amount * value
        else
          bitcoin_api_url = Rails.application.credentials[Rails.env.to_sym][:bitcoin_api_url]
          url = "#{bitcoin_api_url}#{@source_currency}.json"
          res = RestClient.get url
          value = JSON.parse(res.body)['bpi'][@source_currency]['rate_float']

          @amount / value
        end

      else
        exchange_api_url = Rails.application.credentials[Rails.env.to_sym][:currency_api_url]
        exchange_api_key = Rails.application.credentials[Rails.env.to_sym][:currency_api_key]
        url = "#{exchange_api_url}?token=#{exchange_api_key}&currency=#{@source_currency}/#{@target_currency}"
        res = RestClient.get url
        value = JSON.parse(res.body)['currency'][0]['value'].to_f
        
        value * @amount
      end
    rescue RestClient::ExceptionWithResponse => e
      e.response
    end
  end
end