set :port, ENV['PORT']
set :dump_errors, true
set :show_exceptions, false

before { content_type :json }

helpers do
  def rep(status, **params)
    halt status, params.to_json
  end

  def authenticate
    rep 300 unless params[:token]

    uri = URI('http://localhost:4000/authenticate')
    http = Net::HTTP.new(uri.host, uri.port)

    params = URI.encode_www_form(token: params[:token])
    rep = http.post(uri.path, params)

    rep 300 unless rep.is_a?(Net::HTTPSuccess)
  end
end

error Sinatra::NotFound do
  rep 400
end
