require 'net/http'
require 'uri'
require 'rexml/document'
class LinebotController < ApplicationController
    protect_from_forgery except: [:callback]
    #protect_from_forgery
    # ルーティングで設定したcallbackアクションを呼び出す
    def callback
      body = request.body.read
      events = client.parse_events_from(body)
  
      events.each { |event|
        require "date"
        require 'nokogiri'
        require 'open-uri'
        #時刻表示を 時:分 に指定
        now = DateTime.now
        nowTime = now.strftime("%H:%M")
      
      # 1 を入力した時のアクション(DBからデータ取得)
      if event.message["text"].include?("1")
        nextBus = BusTimetableKaiseiSt.all
        nextBusKaisei = []
        nextBus.each do |nextBus|
        time = nextBus.time.strftime("%H:%M")
        if time >= nowTime
          nextBusKaisei << time
        end
      end
      #DBから現在時刻を起点に直近の３つのバスの時刻を出力
      response = 
      "開成発"+nextBusKaisei[0]+"\n
      Next "+nextBusKaisei[1]+"\n
      "+nextBusKaisei[2]+"\n\n\n
      ↓↓番号を選択↓↓\n
      1. 開成駅→会社（シャトルバス）\n
      2. 会社→開成駅（シャトルバス）\n
      3. 電車の運行状況\n
      4. 会社周辺の天気\n
      5. 東京の天気\n\n
      ※半角数字でお願いしまsす。"

      # 2 を入力した時のアクション(DBからデータ取得)
      # 流れは上記と同様なので、割愛

      # 3 を入力した時のアクション(スクレイピングでデータ取得)
    elsif event.message["text"].include?("3")
        urlOdakyu = 'https://www.odakyu.jp/cgi-bin/user/emg/emergency_bbs.pl'
        charset = nil
        htmlOdakyu = open(urlOdakyu) do |f|
        charset = f.charset
        f.read
      end

      docOdakyu = Nokogiri::HTML.parse(htmlOdakyu, nil, charset)
      docOdakyu.xpath('//div[@id="pagettl"]').each do |node|
      #スクレイピング情報の出力
      response = 
        node.css('p').inner_text+"\n\n\n
        ↓↓番号を選択↓↓\n
        1. 開成駅→会社（シャトルバス）\n
        2. 会社→開成駅（シャトルバス）\n
        3. 電車の運行状況\n
        4. 会社周辺の天気\n
        5. 東京の天気\n\n
        ※半角数字でお願いします。"
      end

      # 4 を入力した時のアクション(スクレイピングでデータ取得)
      # 方法は上記と同様なので、割愛
    elsif event.message["text"].include?("4")
      uri = URI.parse('https://www.drk7.jp/weather/xml/27.xml')
      xml = Net::HTTP.get(uri)
      doc = REXML::Document.new(xml)

      xpath = 'weatherforecast/pref/area[1S]'
      

      weather = doc.elements[xpath + '/info/weather'].text # 天気（例：「晴れ」）
    max = doc.elements[xpath + '/info/temperature/range[1]'].text # 最高気温
    min = doc.elements[xpath + '/info/temperature/range[2]'].text # 最低気温
    per00to06 = doc.elements[xpath + '/info/rainfallchance/period[1]'].text # 0-6時の降水確率
    per06to12 = doc.elements[xpath + '/info/rainfallchance/period[2]'].text # 6-12時の降水確率
    per12to18 = doc.elements[xpath + '/info/rainfallchance/period[3]'].text # 12-18時の降水確率
    per18to24 = doc.elements[xpath + '/info/rainfallchance/period[4]'].text # 18-24時の降水確率

    response = 
  "大阪府の天気予報:\n
        天気:"+weather+"\n
        最高気温:"+max+"\n
        最低気温:"+min+"\n
        0-6時の降水確率:"+per00to06+"\n
        6-12時の降水確率:"+per06to12+"\n
        12-18時の降水確率:"+per12to18+"\n
        18-24時の降水確率:"+per18to24+"\n
        ※半角数字でお願いします。"
      # 5 を入力した時のアクション(スクレイピングでデータ取得)
      # 方法は上記と同様なので、割愛

      # 上記以外を入力した時のアクション
    else
    response =
      "↓↓番号を選択↓↓\n
      1. 開成駅→会社（シャトルバス）\n
      2. 会社→開成駅（シャトルバス）\n
      3. 電車の運行状況\n
      4. 会社周辺の天気\n
      5. 東京の天気\n\n
      ※半角数字でお願いします。"
end

        case event
        when Line::Bot::Event::Message
          case event.type
          when Line::Bot::Event::MessageType::Text
            message = {
              type: 'text',
              text: response
            }
            client.reply_message(event['replyToken'], message)
          when Line::Bot::Event::MessageType::Image, Line::Bot::Event::MessageType::Video
            response = client.get_message_content(event.message['id'])
            tf = Tempfile.open("content")
            tf.write(response.body)
          end
        end
      }
      "OK"
    end
  end
