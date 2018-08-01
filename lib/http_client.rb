require 'net/http'
require 'openssl'

class HttpClient

  # 发送Get请求
  def get_request(url, params, header = nil)
    uri = URI(url)
    uri.query = URI.encode_www_form(params)
    req = Net::HTTP::Get.new(uri)
    if header
      req.initialize_http_header(header)
    end
    http = Net::HTTP.new(uri.host, uri.port)
    http.request req
  end

  # 合成Post请求参数
  def post_request(url, params, header = nil)
    uri = URI.parse(url)
    req = Net::HTTP::Post.new(uri)
    req.content_type = 'application/json'
    req.body = params.to_json
    if header
      req.initialize_http_header(header)
    end
    [uri, req]
  end

  # 合成Put请求参数
  def put_request(url, params, header = nil)
    uri = URI.parse(url)
    req = Net::HTTP::Put.new(uri)
    req.content_type = 'application/json'
    req.body = params.to_json
    if header
      req.initialize_http_header(header)
    end
    [uri, req]
  end

  # 合成Delete请求参数
  def del_request(url, header = nil)
    uri = URI.parse(url)
    req = Net::HTTP::Delete.new(uri)
    if header
      req.initialize_http_header(header)
    end
    [uri, req]
  end

  # 发起网络请求
  def submit(uri, request)
    http              = Net::HTTP.new(uri.host, uri.port)
    http.read_timeout = 3000

    if uri.scheme == 'https'
      http.use_ssl     = true
      verify_mode      = OpenSSL::SSL::VERIFY_NONE # OpenSSL::SSL::VERIFY_PEER
      http.verify_mode = OpenSSL::SSL.const_get(verify_mode)
    end

    http.request request
  end

end
