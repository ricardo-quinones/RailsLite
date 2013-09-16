require 'uri'

class Params
  def initialize(req, route_params)
    @params = {}
    @params.merge!(route_params)

    if req.body
      @params.merge!(parse_www_encoded_form(req.body))
    elsif req.query_string
      @params.merge!(parse_www_encoded_form(req.query_string))
    end
  end

  def [](key)
    @params[key]
  end

  def to_s
    @params.to_json.to_s
  end

  private
  def parse_www_encoded_form(www_encoded_form)
    {}.tap do |hash|
      decoded_form = URI.decode_www_form(www_encoded_form)

      decoded_form.each do |key, value|
        keys = parse_key(key)
        nested_hash = hash

        keys.each_with_index do |nested_key, index|
          if index + 1 == keys.count
            nested_hash[nested_key] = value
          else
            nested_hash[nested_key] ||= {}
            nested_hash = nested_hash[nested_key]
          end
        end
      end
    end
  end

  def parse_key(key)
    key.split(/\]\[|\[|\]/)
  end
end