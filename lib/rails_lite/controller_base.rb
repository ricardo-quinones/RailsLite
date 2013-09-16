require 'erb'
require_relative 'params'
require_relative 'session'
require 'debugger'

class ControllerBase
  attr_reader :params

  def initialize(req, res, route_params)
    @req = req
    @res = res

    @already_built_response = false

    @params = Params.new(req, route_params)
  end

  def session
    @session ||= Session.new(@req)
  end

  def already_rendered?
    @already_built_response
  end

  def redirect_to(url)
    @res.status = 302
    @res.header['location'] = url
    session.store_session(@res)
  end

  def render_content(body, content_type)
    @res.content_type = content_type
    @res.body = body
    session.store_session(@res)

    @already_built_response = true
    nil
  end

  def render(template_name)
    template_file = "views/#{self.class.name.underscore}/#{template_name}.html.erb"
    render_content(
      ERB.new(File.read(template_file)).result(binding),
      'text/html'
    )
  end

  def invoke_action(action_name)
    self.send(action_name)
    render action_name unless already_rendered?

    nil
  end
end
