# -*- coding: utf-8 -*-

require 'rubygems'
require 'twitter'
require 'mysql2'

Twitter.configure do |config|
config.consumer_key = CONSUMER_KEY
config.consumer_secret = CONSUMER_SECRET
config.oauth_token = OAUTH_TOKEN
config.oauth_token_secret = OAUTH_TOKEN_SECRET
end

@db = Mysql2::Client.new(host: "localhost", username: "root", password: "", database: "crawler")

def search( word )
  hit_counter = 0
  add_counter = 0
  file = File.open("tweet_#{Time.now.strftime("%Y%m%d")}", "a") { | file |
    Twitter.search(word).results.each { |result|
      hit_counter += 1
      next if @db.query("SELECT id FROM tweets WHERE tweet_id = #{result.id}").count > 0
      text = result.text.gsub('\\', '\\\\').gsub("\r", "").gsub("\n", "\\n").gsub("\t", "\\t")
      file.puts "#{result.id}\t#{result.geo.to_s}\t#{result.from_user}\t" + "#{result.created_at}\t#{text}"
      @db.query("INSERT INTO tweets (tweet_id) VALUES (#{result.id})")
      add_counter += 1
    }
  }
  puts "search : #{word} - #{add_counter}/#{hit_counter}"
end


words = [
    'あ', 'い', 'う', 'え', 'お',
    'か', 'き', 'く', 'け', 'こ',
    'さ', 'し', 'す', 'せ', 'そ',
    'た', 'ち', 'つ', 'て', 'と',
    'な', 'に', 'ぬ', 'ね', 'の',
    'は', 'ひ', 'ふ', 'へ', 'ほ',
    'ま', 'み', 'む', 'め', 'も',
    'や', 'ゆ', 'よ', 'ら', 'り',
    'る', 'れ', 'ろ', 'わ', 'ゐ',
    'ゑ', 'を', 'ん',
    'が', 'ぎ', 'ぐ', 'げ', 'ご',
    'ざ', 'じ', 'ず', 'ぜ', 'ぞ',
    'だ', 'ぢ', 'づ', 'で', 'ど',
    'ば', 'び', 'ぶ', 'べ', 'ぼ',
    'ぱ', 'ぴ', 'ぷ', 'ぺ', 'ぽ',

    'ア', 'イ', 'ウ', 'エ', 'オ',
    'カ', 'キ', 'ク', 'ケ', 'コ',
    'サ', 'シ', 'ス', 'セ', 'ソ',
    'タ', 'チ', 'ツ', 'テ', 'ト',
    'ナ', 'ニ', 'ヌ', 'ネ', 'ノ',
    'ハ', 'ヒ', 'フ', 'ヘ', 'ホ',
    'マ', 'ミ', 'ム', 'メ', 'モ',
    'ヤ', 'ユ', 'ヨ',
    'ラ', 'リ', 'ル', 'レ', 'ロ',
    'ワ', 'ヲ', 'ン',
    'ガ', 'ギ', 'グ', 'ゲ', 'ゴ',
    'ザ', 'ジ', 'ズ', 'ゼ', 'ゾ',
    'ダ', 'ヂ', 'ヅ', 'デ', 'ド',
    'バ', 'ビ', 'ブ', 'ベ', 'ボ',
    'パ', 'ピ', 'プ', 'ペ', 'ポ'
]

prevs = []
while true
  begin
    word = words[rand(words.size - 1)]
    if prevs.index( word )
      next
    end
    prevs.push( word )
    search( word )
    sleep 1.3
  rescue StandardError, Timeout::Error => e
    puts e.message
    sleep 3
  ensure
    prevs.slice!(0) if prevs.size > 20
  end
end
