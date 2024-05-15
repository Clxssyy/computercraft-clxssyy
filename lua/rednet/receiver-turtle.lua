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

function come(posX, posY , posZ)
  local x, y, z = gps.locate()
  local dx = posX - x
  local dy = posY - y
  local dz = posZ - z
  local distance = math.sqrt(dx * dx + dy * dy + dz * dz)
  local fuel = turtle.getFuelLevel()
  local needed = distance + 1

  if fuel < needed then
    rednet.send(id, "ERROR - Need more fuel", protocol)
    return
  end

  rednet.send(id, "Moving to " .. x .. ", " .. y .. ", " .. z, protocol)

  while x ~= posX or y ~= posY or z ~= posZ do
    if x < posX then
      turtle.forward()
      x = x + 1
    elseif x > posX then
      turtle.back()
      x = x - 1
    end

    if y < posY then
      turtle.up()
      y = y + 1
    elseif y > posY then
      turtle.down()
      y = y - 1
    end

    if z < posZ then
      turtle.forward()
      z = z + 1
    elseif z > posZ then
      turtle.back()
      z = z - 1
    end
  end

  rednet.send(id, "Arrived at " .. x .. ", " .. y .. ", " .. z, protocol)
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
    elseif message[1] == "come" then
      if not message[3] or not message[4] or not message[5] then
        rednet.send(id, "ERROR - Missing arguments", protocol)
        return
      end
      come(tonumber(message[3]), tonumber(message[4]), tonumber(message[5]))
      return
    elseif message[1] == "refuel" then
      for i = 1, 16 do
        turtle.select(i)
        if turtle.refuel(0) then
          turtle.refuel()
          rednet.send(id, "Refueled", protocol)
          return
        end
      end
      rednet.send(id, "No fuel", protocol)
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
