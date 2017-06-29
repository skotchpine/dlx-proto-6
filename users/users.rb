#!/usr/bin/env ruby

require 'jwt'
require 'json'
require 'bcrypt'
require 'sequel'
require 'sinatra'

load File.join(__dir__, 'config.rb')

Database = Sequel.connect("postgres://#{ENV['USERS_DB']}")
#Database.run <<~SQL
#  CREATE TABLE IF NOT EXISTS users
#  ( handle VARCHAR(255) NOT NULL
#  , hash   VARCHAR(255) NOT NULL
#  , salt   VARCHAR(255) NOT NULL
#  , id     INT          PRIMARY KEY
#  )
#SQL

post '/users' do
  handle    = params['handle']
  password1 = params['password1']
  password2 = params['password2']

  users = Database[:users]

  rep 300 unless \
    (  handle && password1 && password2 ) \
    || password1 == password2 \
    || users.where(handle: handle).none?

  salt = BCrypt::Engine.generate_salt
  hash = BCrypt::Engine.hash_secret(password1, salt)

  begin
    users.insert(handle: handle, salt: salt, hash: hash)
    rep 200
  rescue SQLite3::SQLException
    rep 500
  end
end

post '/sessions' do
  handle   = params['handle']
  password = params['password']

  rep 300 unless handle && password

  users = Database[:users]
  user = users.select(:hash, :salt).where(handle: handle).first
  rep 300 unless user

  hash, salt = *user.values
  rep 300 unless hash == BCrypt::Engine.hash_secret(password, salt)

  data = { 'issue' => 'DLX', 'expire' => DateTime.now }
  salt = '37DCCDD3A16DD1177DEF9ECF322E4F40'
  token = JWT.encode(data, salt)
  rep 200, token
end

post '/authenticate' do
  rep 300 unless params['token']

  salt = '37DCCDD3A16DD1177DEF9ECF322E4F40'
  begin
    data, _ = *JWT.decode(params['token'], salt)
  rescue JWT::DecodeError
    rep 300
  end

  if DateTime.parse(data['expire']) > DateTime.now
    rep 300
  else
    rep 200
  end
end
