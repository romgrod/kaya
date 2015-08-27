require 'socket'

server = TCPServer.new 2001 # Server bound to port 2000



loop do
  client = server.accept    # Wait for a client to connect

  print "peeraddr: "
  print client.peeraddr

  1000.times do |i|
    client.puts i
  end

  client.puts "Fin"
  client.close
end

server.close