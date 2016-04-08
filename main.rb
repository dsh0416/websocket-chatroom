require 'sinatra'
require 'faye/websocket'
require 'json'
require './database.rb'

configure {set :server, :puma}
Faye::WebSocket.load_adapter('puma')

chat_room_sockets = Hash.new{|h, k| h[k] = []}
db = Database.new ':memory:'
db.initialize_data

get '/room' do
  # Get room list
  JSON.generate chat_room_sockets.each_key.to_a
end

get '/room/:id' do |id|
  # Enter a room
  ws = Faye::WebSocket.new(request.env)

  ws.on :open do |event|
    chat_room_sockets[id] << ws
    ws.send(JSON.generate(db.select_history(id)))
  end

  ws.on :message do |event|
    msg = event.data
    db.insert_msg(id, msg)
    chat_room_sockets[id].each do |s|
      s.send(JSON.generate([msg]))
    end
  end

  ws.on :close do |event|
    chat_room_sockets[id].delete(ws)
  end

  ws.rack_response
end

get '/' do
  redirect '/index.html'
end