class LinebotController < ApplicationController
  protect_from_forgery except: [:callback]
  require 'line/bot'

  def callback
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      error 400 do 'Bad Request' end
    end
    events = client.parse_events_from(body)

    events.each do |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          message = {
            type: 'text',
            text: event.message['text']
          }
        end
      end
      client.reply_message(event['replyToken'], message)
      #binding.pry
    end
    head :ok
  end

private

# LINE Developers登録完了後に作成される環境変数の認証
  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = "cfda0db29a9a984ecf806d65ac7614d9"
      config.channel_token = "lWtl+Wyg/kPrxrE+rKKd+UxhPCqrcam6CP5tBM6YhJ19pKyAFziy0DitxcOEUPckYmlmXnrKKwDcQ8GbvlMEmlYz+IS6/S4Q7MOOte5lWUXdcSVbG8wJ6vLja9Nw9ZnRwQNl5uehp0tKxMDemktbmQdB04t89/1O/w1cDnyilFU="
    }
  end
end