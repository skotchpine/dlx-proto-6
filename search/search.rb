require 'yt'
require 'json'
require 'sinatra'

load File.join(__dir__, 'config.rb')

Yt.configure do |config|
  config.api_key = 'AIzaSyAleO6uQs_udPO41-pf1GQvULEd4Mgm6-E'
end

post '/search' do
  authenticate
  rep 300 unless params['query']

  results = 
    Yt::Collections::Videos.new
      .where(q: params['query'])
      .take(20)
      .map do |result|
        {
          id:           result.id,
          title:        result.snippet.title,
          description:  result.snippet.description,
          thumbnailUrl: result.snippet.thumbnails['default']['url'],
        }
      end

  rep 200, results
end
