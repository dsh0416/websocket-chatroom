require 'sinatra'
require 'sinatra-websocket'
require 'json'
require './database.rb'

chat_room_sockets = Hash.new{|h, k| h[k] = []}
db = Database.new ':memory:'
db.initialize_data

get '/room' do
  # Get room list
  JSON.generate chat_room_sockets.each_key.to_a
end

post '/login' do
  req = JSON.parse(request.body.read)
  # If username exists
  sql = db.search_user(req['username'])
  if sql == []
    db.insert_user(req['username'], req['password'])
    return JSON.generate({result: 1})
  else
    if sql[0][0] == req['password']
      return JSON.generate({result: 1})
    else
      return JSON.generate({result: -1})
    end
  end
end

get '/room/:id' do |id|
  # Enter a room
  request.websocket do |ws|
    ws.onopen do
      chat_room_sockets[id] << ws
      EM.next_tick do
        ws.send(JSON.generate(db.select_history(id)))
      end
    end
    ws.onmessage do |msg|
      EM.next_tick do
        db.insert_msg(id, msg)
        chat_room_sockets[id].each do |s|
          s.send(JSON.generate([msg]))
        end
      end
    end
    ws.onclose do
      chat_room_sockets[id].delete(ws)
    end
  end
end

get '/' do
  redirect '/index.html'
end