if not pocket then
  return
end

protocol = "secret"
rednet.open("back")

while true do
  local message = io.read()
  rednet.send(13, message, protocol)
end