protocol = "secret"
rednet.open("right")

while true do
  id, message = rednet.receive(protocol)
  print("Received message from " .. id .. ": " .. message)
end