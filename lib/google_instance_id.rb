require "google_instance_id/version"
require 'httparty'
require 'cgi'
require 'json'
require 'hashie'

class GoogleInstanceId
  include HTTParty
  base_uri 'https://iid.googleapis.com/iid'
  default_timeout 30
  format :json

attr_accessor :timeout, :api_key

  def initialize(api_key, client_options = {})
    @api_key = api_key
    @client_options = client_options
  end

  def add_topic(registration_tokens, topic)
    manage_relationship_maps(registration_tokens, topic, :add)
  end

  def remove_topic(registration_tokens, topic)
    manage_relationship_maps(registration_tokens, topic, :remove)
  end

  def info(registration_token)
    response = self.class.get("/info/#{registration_token}?details=true", build_params)
    Hashie::Mash.new(response) if response.code == 200
  end

  private

  def headers
    { 'Authorization' => "key=#{@api_key}", 'Content-Type' => 'application/json' }
  end

  def manage_relationship_maps(registration_tokens, topic, action = :add)
    body = { registration_tokens: registration_tokens, to: topic }
    path = action == :add ? '/v1:batchAdd' : '/v1:batchRemove'
    response = self.class.post(path, build_params(body))
    Hashie::Mash.new(build_manage_relationship_response(response, registration_tokens))
  end

  def build_params(body = nil)
    params = { headers: headers }
    params[:body] = body.to_json if body
    params.merge(@client_options)
    params
  end

  # Reference https://developers.google.com/instance-id/reference/server#create_a_relation_mapping_for_an_app_instance
  def build_manage_relationship_response(response, registration_tokens)
    body = response.body.nil? ?  {} : JSON.parse(response.body)
    response_hash = { body: body, headers: response.headers, status_code: response.code, errors: [] }
    if response.code == 200
      body['results'].each_with_index do |result, i|
        if result['error']
          response_hash[:errors] << { error: result['error'], registration_token: registration_tokens[i] }
        end
      end
    end
    response_hash
  end
end
