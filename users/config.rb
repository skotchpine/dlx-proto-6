set :bind, '0.0.0.0'
set :port, ENV['PORT']
#set :dump_errors, true
#set :show_exceptions, false

before { content_type :json }

helpers do
  def rep(status, **params)
    halt status, params.to_json
  end

  def authenticate
    rep 300 unless params[:token]

    uri = URI("http://users:#{ENV['USERS_PORT']}/authenticate")
    http = Net::HTTP.new(uri.host, uri.port)

    args = URI.encode_www_form(token: params[:token])
    response = http.post(uri.path, args)

    rep 300 unless response.is_a?(Net::HTTPSuccess)
  end
end

error Sinatra::NotFound do
  rep 400
end
