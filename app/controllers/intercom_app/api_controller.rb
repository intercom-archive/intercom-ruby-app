require 'net/http'

module IntercomApp
  class ApiController < AuthenticatedController

    INTERCOM_API = "https://api.intercom.io/"

    def proxy
      uri = URI("#{INTERCOM_API}#{params[:path]}")
      uri.query = URI.encode_www_form(request.query_parameters)
      Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
        request = Net::HTTP::Get.new(uri)
        request['Accept'] = 'application/json'
        request.basic_auth app_session[:intercom_token], ''
        render json: http.request(request).body
      end
    end

  end
end
