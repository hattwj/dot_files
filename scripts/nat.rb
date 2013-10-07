re 'socket'

remote_host = ARGV.first

# Punches hole in firewall
punch = UDPSocket.new
punch.bind('', 6311)
punch.send('', 0, remote_host, 6311)
punch.close

# Bind for receiving
udp_in = UDPSocket.new
udp_in.bind('0.0.0.0', 6311)
puts "Binding to local port 6311"

loop do
  # Receive data or time out after 5 seconds
  if IO.select([udp_in], nil, nil, rand(4))
        data = udp_in.recvfrom(1024)
        remote_port = data[1][1]
        remote_addr = data[1][3]
        puts "Response from #{remote_addr}:#{remote_port} is #{data[0]}"
  else
        puts "Sending a little something.."
        udp_in.send(Time.now.to_s, 0, remote_host, 6311)
  end
end
