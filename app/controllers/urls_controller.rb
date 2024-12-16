class UrlsController < ApplicationController
 protect_from_forgery with: :null_session
 require 'digest'
 require 'redis'

 before_action :rate_limit, only: [:shorten]

 # Redisクライアントを初期化
 REDIS = Redis.new

 # レートリミッター
 def rate_limit
   client_ip = request.remote_ip
   key = "rate_limit:#{client_ip}"
   limit = 10 # 最大リクエスト数
   window = 60 # 秒

   current_count = REDIS.get(key).to_i
   if current_count >= limit
     render json: { error: 'Rate limit exceeded' }, status: 429
   else
     REDIS.multi do
       REDIS.incr(key)
       REDIS.expire(key, window) if current_count == 0
     end
   end
 end

 # 短縮URL生成
 def shorten
   original_url = params[:url]
   if original_url.blank? || !valid_url?(original_url)
     return render json: { error: 'Invalid URL' }, status: 400
   end

   short_url = Digest::SHA256.hexdigest(original_url)[0..5]
   url = Url.find_or_create_by(original_url: original_url, short_url: short_url)

   render json: { short_url: "#{request.base_url}/#{url.short_url}" }
 end

 # リダイレクト
 def redirect
   url = Url.find_by(short_url: params[:short_url])
   if url
     redirect_to url.original_url
   else
     render json: { error: 'URL not found' }, status: 404
   end
 end

 private

 def valid_url?(url)
   uri = URI.parse(url)
   %w[http https].include?(uri.scheme)
 rescue URI::InvalidURIError
   false
 end
end
