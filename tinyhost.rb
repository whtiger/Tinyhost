#!/usr/bin/ruby

require 'socket'

def host(sock)

puts "New connection"
x=""
item=""
while (x != "\r\n")
	x = sock.readline
	if (item.empty?)
		r=x.match(/GET \/(\w+) HTTP\/\d\.\d/)
		if (!r.nil?)
			item=r[1]
		end
	end
end

puts "Request for #{item}"

target=""

f = File.open("index.txt","r");
f.each_line do |line|
	puts line
	r=line.match(/(\w+) (.*)/)
	if (!r.nil?)
		if (r[1]==item)
			target=r[2]
		end
	end
end

puts "File: #{target}"


if (target.empty?)
	sock.print("HTTP/1.1 404 Not Found\r\n")
	text = "#{item} not found."
	sock.print("Content-Type: text/plain\r\n")
	sock.print("Content-Length: " + text.length.to_s + "\r\n")
	sock.print("\r\n")
	sock.print(text)
else

	t = File.open(target, "r")
	
	targetname = File.basename(target)
	
	puts "Sending headers"
	sock.print("HTTP/1.1 200 OK\r\n")
	sock.print("Content-Disposition: attachment; filename=\"#{targetname}\"\r\n")
	sock.print("Content-Length: " + t.stat.size.to_s + "\r\n")
	sock.print("\r\n");

	line=""
	puts "Sending file"
	while (1) do
		line=t.read(1024);
		break if line.nil?
		sock.print(line)
	end
end
	puts "Done"


t.close

end

server = TCPServer.open(8500);
loop do
	Thread.start(server.accept) do |client|
		host(client)
		client.close
	end
end
