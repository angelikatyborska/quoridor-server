require 'faye/websocket'
require_relative 'lib/quoridor/lobby'

lobby = Quoridor::Lobby.new

App = lambda do |env|
  if Faye::WebSocket.websocket?(env)
    ws = Faye::WebSocket.new(env)
    ping_loop = nil
    player = nil

    ws.on :open do |event|
      puts [env['REMOTE_ADDR'], :open]

      player = lobby.add_player(ws)

      ping_loop = EM.add_periodic_timer(3) do
        ws.ping
      end
    end

    ws.on :message do |event|
      puts [env['REMOTE_ADDR'], :message, event.data]

      begin
        lobby.reception_desk(player, event.data)
      rescue StandardError => e
        ws.send(e.message)
      end

    end

    ws.on :close do |event|
      EM.cancel_timer(ping_loop)

      lobby.remove_player(player)
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