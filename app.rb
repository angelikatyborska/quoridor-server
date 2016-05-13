require 'faye/websocket'

App = lambda do |env|
  if Faye::WebSocket.websocket?(env)
    ws = Faye::WebSocket.new(env)
    ping_loop = nil

    ws.on :open do |event|
      puts [:open]
      ping_loop = EM.add_periodic_timer(3) do
        ws.ping
      end
    end

    ws.on :message do |event|
      puts [:message, event.data]
      ws.send('echo: ' + event.data)
    end

    ws.on :close do |event|
      EM.cancel_timer(ping_loop)

      p [:close, event.code, event.reason]
      ws = nil
    end

    # Return async Rack response
    ws.rack_response

  else
    # Normal HTTP request
    [200, {'Content-Type' => 'text/plain'}, ['Hello']]
  end
end