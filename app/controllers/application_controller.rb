# gem 'line-bot-api'を使えるように宣言
require 'line/bot'


class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :validate_signature, except: [:new, :create]
  def validate_signature
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      error 400 do 'Bad Request' end
    end
  end  

  def client
    @client ||= Line::Bot::Client.new { |config|
      # ローカルで動かすだけならベタ打ちでもOK。
      config.channel_secret = "cfda0db29a9a984ecf806d65ac7614d9"
      config.channel_token = "lWtl+Wyg/kPrxrE+rKKd+UxhPCqrcam6CP5tBM6YhJ19pKyAFziy0DitxcOEUPckYmlmXnrKKwDcQ8GbvlMEmlYz+IS6/S4Q7MOOte5lWUXdcSVbG8wJ6vLja9Nw9ZnRwQNl5uehp0tKxMDemktbmQdB04t89/1O/w1cDnyilFU="
    }
  end
end