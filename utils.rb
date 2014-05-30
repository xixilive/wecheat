require 'digest/sha1'

module Wechat
  module Utils
    extend self

    def rand_openid
      chars.shuffle.slice(0,28).join
    end

    def rand_appid
      chars.shuffle.slice(0,16).unshift('wx').join.downcase
    end

    def rand_secret
      chars.shuffle.slice(0,32).join.downcase
    end

    def rand_token
      rand_openid + rand_openid
    end

    def sign_params params = {}, token
      sign = Digest::SHA1.hexdigest([token, params[:timestamp], params[:nonce]].collect(&:to_s).compact.sort.join)
      params.merge(signature: sign)
    end

    private
    def chars
      @chars ||= (('a'..'z').to_a | ('A'..'Z').to_a | (0..9).to_a)
    end
  end
end