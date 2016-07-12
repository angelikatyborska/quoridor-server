require 'faye/websocket'
require_relative 'lib/quoridor/lobby'

# TODO: add exception_notification middleware

lobby = Quoridor::Lobby::ReceptionDesk.new

App = lambda do |env|
  if Faye::WebSocket.websocket?(env)
    ws = Faye::WebSocket.new(env)
    ping_loop = nil
    player = nil

    ws.on :open do |event|
      puts [env['REMOTE_ADDR'], :open]

      player = Quoridor::Lobby::Player.new(ws)

      ping_loop = EM.add_periodic_timer(3) do
        ws.ping
      end
    end

    ws.on :message do |event|
      puts [env['REMOTE_ADDR'], :message, event.data]

      begin
        ws.send(lobby.request(player, event.data).to_json)
      rescue StandardError => e
        ws.send({type: 'ERROR', data: e.message}.to_json)
      end

    end

    ws.on :close do |event|
      EM.cancel_timer(ping_loop)

      begin
        lobby.request(player, {type: 'LEAVE', data: {}}.to_json)
      rescue Exception => e
        puts e
      end

      p [env[ 'REMOTE_ADDR'], :close, event.code, event.reason]
      ws = nil
    end

    # Return async Rack response
    ws.rack_response

  else
    # Normal HTTP request
    [200, {'Content-Type' => 'text/plain'}, ['Hello']]
  end
end

# TODO: think about DDoS