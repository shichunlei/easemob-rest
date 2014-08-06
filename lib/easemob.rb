require 'json'
require 'net/http'
require 'openssl'
require 'digest/md5'
require_relative 'constants'
require_relative 'http_client'

module IM

  class Easemob
    attr_reader :access_token, :email

    def initialize(email)
      @email = email
      @http_client = HttpClient.new
    end

    # 登录并授权
    def authorize
      url = Constants::EASEMOB_BASE_URL + '/token'
      params = {
        grant_type: "client_credentials",
        client_id: Constants::CLIENT_ID,
        client_secret: Constants::CLIENT_SECRET
      }
      uri, req = @http_client.post_request(url, params)
      res = @http_client.submit(uri, req)
      @access_token = JSON.parse(res.body)['access_token'] if res.is_a?(Net::HTTPSuccess)
      # puts @access_token
    end

    # 授权注册模式-创建帐号
    def create(email)
      usr_name = gen_esmb_usr(email)
      authorization = "Bearer " + @access_token
      header = { "Authorization" => authorization }
      url = Constants::EASEMOB_BASE_URL + '/users'
      params = {
        username: usr_name,
        password: '123456'  # 暂用账号的作为密码
      }
      uri, req = @http_client.post_request(url, params, header)
      res = @http_client.submit(uri, req)
      puts JSON.parse(res.body) if res.is_a?(Net::HTTPSuccess)
    end

    # 删除已有账号
    def delete(email)
      usr_name = gen_esmb_usr(email)
      authorization = "Bearer " + @access_token
      header = { "Authorization" => authorization }
      url = Constants::EASEMOB_BASE_URL + '/users/' + usr_name
      uri, req = @http_client.del_request(url, header)
      res = @http_client.submit(uri, req)
      puts JSON.parse(res.body) if res.is_a?(Net::HTTPSuccess)
    end

    # 管理员发送消息给用户或者群组
    def send_message(usr_name, target_name)
      

    end

    private
      # 根据邮箱生成环信账号
      def gen_esmb_usr(email)
        Digest::MD5.hexdigest(email)
      end    
  end
end

# Test method
easemob = IM::Easemob.new('cronnorc@gmail.com')
# Login and authorize
easemob.authorize
# Create user
# easemob.create('cronnorc@gmail.com')
# Delete user
# easemob.delete('cronnorc@gmail.com')

