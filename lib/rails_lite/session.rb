require 'json'
require 'webrick'

class Session
  def initialize(req)
    cookie = req.cookies.find { |name| name == '_rails_lite_app' }
    @data = cookie.nil? ? {} : JSON.parse(cookie)
  end

  def [](key)
    @data[key]
  end

  def []=(key, val)
    @data[key] = val
  end

  def store_session(res)
    new_cookie = WEBrick::Cookie.new(
      'rails_lite_app',
      @data.to_json
    )
    res.cookies << new_cookie
  end
end
