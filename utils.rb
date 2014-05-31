require 'digest/sha1'
require 'fileutils'

module Wecheat
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

    def log_received_message message
      File.open(message_file, 'w'){|f| f.puts message }
      File.open(message_tmp_file, 'w'){|f| f.puts message }
    end

    def read_received_message
      msg = JSON.parse(File.open(message_tmp_file, 'r').read) rescue nil
      FileUtils.rm_rf(message_tmp_file)
      msg
    end

    private
    def message_file
      File.expand_path('../db/message.log', __FILE__)
    end

    def message_tmp_file
      File.expand_path('../db/message.tmp', __FILE__)
    end

    def chars
      @chars ||= (('a'..'z').to_a | ('A'..'Z').to_a | (0..9).to_a)
    end
  end
end