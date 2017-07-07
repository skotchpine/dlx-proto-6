#!/usr/bin/env ruby

require 'sequel'
require 'sinatra'

load File.join(__dir__, 'config.rb')

p DB_PATH = ENV['TAGS_DB_PATH']
p DB_USER = ENV['TAGS_DB_USER']
p DB_PASS = ENV['TAGS_DB_PASS']
p DB_NAME = ENV['TAGS_DB_NAME']

sleep 4

Database = Sequel.connect("postgres://#{DB_USER}:#{DB_PASS}@#{DB_PATH}/#{DB_NAME}")
Database.run <<~SQL
  CREATE TABLE IF NOT EXISTS tags
  ( start VARCHAR(255) NOT NULL
  , stop  VARCHAR(255) NOT NULL
  , name  VARCHAR(255) NOT NULL
  , uuid  VARCHAR(255) NOT NULL
  , url   VARCHAR(255) NOT NULL
  , id    INT          PRIMARY KEY
  )
SQL

get '/tags/index' do
  authenticate
  tags = Database[:tags]
           .select(:start, :stop, :name, :uuid, :url).to_a
  rep 200, tags: tags 
end

post '/tags/create' do
  authenticate
  %i(start stop name url).each do |param|
    rep 300 unless params[param]
  end

  uuid = SecureRandom.uuid

  Database[:tags].insert \
    start: params[:start],
    stop:  params[:stop],
    name:  params[:name],
    url:   params[:url],
    uuid:  uuid

  rep 200, uuid: uuid
end

get '/tags/:uuid/show' do
  authenticate
  rep 300 unless params[:uuid]

  tag = Database[:tags]
          .select(:start, :stop, :name, :uuid, :url)
          .where(uuid: uuid)
  rep 200, tag: tag
end

post '/tags/:uuid/update' do
  authenticate
  rep 300 unless params[:uuid]

  updates =
    %i(start stop name uuid url).each_with_object({}) do |key, sum|
      sum[key] = params[key] if params[key]
    end
  Database[:tags].update(updates).where(uuid: params[:uuid])
  rep 200
end

delete '/tags/:uuid/destroy' do
  authenticate
  rep 300 unless params[:uuid]

  Database[:tags].where(uuid: params[:uuid]).delete
  rep 200
end
