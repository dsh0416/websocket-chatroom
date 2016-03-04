require 'sinatra'
require 'sinatra-websocket'
require 'json'

user = {}
chat_room_sockets = Hash.new{|h, k| h[k] = []}

post '/login' do
  # Login or register
  data = JSON.parse request.body.read
  if user.include? data['username']
    if user[data['username']] == data['password']
      return JSON.generate({result: 1})
    else
      return JSON.generate({result: -1})
    end
  else
    user[data['username']] = data['password']
    return JSON.generate({result: 1})
  end
end

get '/room' do
  # Get room list
  JSON.generate chat_room_sockets.each_key.to_a
end

get '/room/:id' do |id|
  # Enter a room
  request.websocket do |ws|
    ws.onopen do
      chat_room_sockets[id] << ws
    end
    ws.onmessage do |msg|
      EM.next_tick { chat_room_sockets[id].each{|s| s.send(msg) } }
    end
    ws.onclose do
      chat_room_sockets[id].delete(ws)
    end
  end
end