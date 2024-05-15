if not turtle then
  return
end

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

function move()
  while true do
    turtle.forward()
  end
end

function receiveMessages()
  while true do
    id, message = rednet.receive(protocol)
    receive(message[1], id)
  
    if message[1] == "location" then
      local x, y, z = gps.locate()
      rednet.send(id, "Location: " .. x .. ", " .. y .. ", " .. z, protocol)
      return
    elseif message[1] == "move" then
      rednet.send(id, "Moving...", protocol)
      parallel.waitForAny(move, receiveMessages)
      return
    elseif message[1] == "stop" then
      rednet.send(id, "Stopping...", protocol)
      return
    elseif message[1] == "test" then
      for i = 3, #message do
        rednet.send(id, "arg ".. i .. " " .. message[i], protocol)
      end
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
