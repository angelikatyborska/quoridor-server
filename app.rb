require 'faye/websocket'
require_relative 'lib/quoridor'

quoridor = Quoridor.new

App = lambda do |env|
  if Faye::WebSocket.websocket?(env)
    ws = Faye::WebSocket.new(env)
    ping_loop = nil
    player = nil

    ws.on :open do |event|
      puts [env['REMOTE_ADDR'], :open]

      player = quoridor.add_player(ws)

      ping_loop = EM.add_periodic_timer(3) do
        ws.ping
      end
    end

    ws.on :message do |event|
      puts [env['REMOTE_ADDR'], :message, event.data]

      quoridor.players[player.id].nickname = event.data
      ws.send(
        quoridor.players.map{ |id, player| player.nickname }.join(' and ')
      )
    end

    ws.on :close do |event|
      EM.cancel_timer(ping_loop)

      quoridor.remove_player(player.id)
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