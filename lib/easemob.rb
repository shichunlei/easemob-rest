require 'json'
require 'digest/md5'
require_relative 'constants'
require_relative 'http_client'

module IM

  class Easemob
    attr_reader :access_token

    def initialize
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
    def create(email, passwd)
      usr_name = gen_usr_name(email)
      authorization = "Bearer " + @access_token
      header = { "Authorization" => authorization }

      url = Constants::EASEMOB_BASE_URL + '/users'
      params = {
        username: usr_name,
        password: passwd
      }
      uri, req = @http_client.post_request(url, params, header)
      res = @http_client.submit(uri, req)
      JSON.parse(res.body) if res.is_a?(Net::HTTPSuccess)
    end

    # 删除已有账号
    def delete(email)
      usr_name = gen_usr_name(email)
      authorization = "Bearer " + @access_token
      header = { "Authorization" => authorization }
      url = Constants::EASEMOB_BASE_URL + '/users/' + usr_name
      uri, req = @http_client.del_request(url, header)
      res = @http_client.submit(uri, req)
      JSON.parse(res.body) if res.is_a?(Net::HTTPSuccess)
    end

    # 管理员发送消息给用户或者群组
    def send_message(from, msg, to_type, to_list, ext)
      authorization = "Bearer " + @access_token
      header = { "Authorization" => authorization }

      url = Constants::EASEMOB_BASE_URL + '/messages'
      params = {
        target_type: to_type,
        target: to_list,
        msg: msg,
        from: from,
        ext: ext
      }
      uri, req = @http_client.post_request(url, params, header)
      res = @http_client.submit(uri, req)
      JSON.parse(res.body) if res.is_a?(Net::HTTPSuccess)
    end

    # 将用户绑定为管理员
    def bind_admin(usr_name)
      authorization = "Bearer " + @access_token
      header = { "Authorization" => authorization }

      url = Constants::EASEMOB_BASE_URL + '/users/' + usr_name + '/roles/admin'
      uri, req = @http_client.post_request(url, {}, header)
      res = @http_client.submit(uri, req)
      JSON.parse(res.body) if res.is_a?(Net::HTTPSuccess)
    end

    private
      # 根据邮箱生成环信账号
      def gen_usr_name(email)
        Digest::MD5.hexdigest(email)
      end    
  end
end

# easemob = IM::Easemob.new

# Login and authorize
# easemob.authorize

# Create user
# easemob.create('cronnorc@gmail.com', 'udesk')

# Delete user
# easemob.delete('cronnorc@gmail.com')

# Bind to admin
# curl -X POST -H 'Authorization: Bearer {token}' -H 'Content-Type: application/json' 'https://a1.easemob.com/{orgName}/{appName}/users/{username}/roles/admin'
