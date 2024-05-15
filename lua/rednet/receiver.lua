function receive(message, id)
  term.setTextColor(colors.lime)
  io.write("[" .. id .. "] ")
  term.setTextColor(textColor)
  print(message)
end

function showHeader()
  term.clear()
  term.setCursorPos(1, 1)
  io.write("-----={ ")
  term.setTextColor(colors.lime)
  io.write("Classy Receiver")
  term.setTextColor(textColor)
  io.write(" }=-----\n")
end

function receiveMessages()
  while true do
    id, message = rednet.receive(protocol)
    receive(message, id)
  
    if message == "location" then
      local x, y, z = gps.locate()
      rednet.send(id, "Location: " .. x .. ", " .. y .. ", " .. z, protocol)
      return
    end
  
    rednet.send(id, "ERROR - No action", protocol)
  end
end

function main()
  showHeader()

  while true do
    receiveMessages()
  end
end

textColor = colors.white
protocol = "secret"
rednet.open("right")
rednet.host(protocol, tostring(os.getComputerID()))
main()
