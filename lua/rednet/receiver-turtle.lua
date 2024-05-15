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

function calibrate(dig)
  rednet.send(id, "Calibrating...", protocol)
  local x, y, z = gps.locate()
  local facing = nil
  local turns = 0

  if turtle.detect() then
    if dig then
      turtle.dig()
    else
      repeat
        turtle.turnRight()
        turns = turns + 1
      until not turtle.detect() or turns == 4

      if turns == 4 then
        rednet.send(id, "ERROR - Stuck", protocol)
        return
      end
    end

    turtle.forward()
  else
    turtle.forward()
  end
  local x2, y2, z2 = gps.locate()
  local dx = x2 - x
  local dy = y2 - y
  local dz = z2 - z

  if dz == 1 then
    facing = "south"
  elseif dz == -1 then
    facing = "north"
  elseif dx == 1 then
    facing = "east"
  elseif dx == -1 then
    facing = "west"
  end

  rednet.send(id, "Facing: " .. facing, protocol)
  return x2, y2, z2, facing
end

function face(face, facing)
  if face == "north" then
    if facing == "east" then
      turtle.turnRight()
    elseif facing == "south" then
      turtle.turnRight()
      turtle.turnRight()
    elseif facing == "west" then
      turtle.turnLeft()
    end
    return "north"
  elseif face == "east" then
    if facing == "north" then
      turtle.turnRight()
    elseif facing == "south" then
      turtle.turnLeft()
    elseif facing == "west" then
      turtle.turnRight()
      turtle.turnRight()
    end
    return "east"
  elseif face == "south" then
    if facing == "north" then
      turtle.turnRight()
      turtle.turnRight()
    elseif facing == "east" then
      turtle.turnRight()
    elseif facing == "west" then
      turtle.turnLeft()
    end
    return "south"
  elseif face == "west" then
    if facing == "north" then
      turtle.turnLeft()
    elseif facing == "east" then
      turtle.turnRight()
      turtle.turnRight()
    elseif facing == "south" then
      turtle.turnRight()
    end
    return "west"
  end
end

function come(posX, posY , posZ, dig)
  if dig ~= "true" then
    dig = false
  else
    dig = true
  end

  local x, y, z, facing = calibrate(dig)
  posX = math.floor(tonumber(posX))
  posY = math.floor(tonumber(posY)) - 1
  posZ = math.floor(tonumber(posZ))

  local dx = x - posX
  local dy = y - posY
  local dz = z - posZ
  local distance = math.sqrt(dx * dx + dy * dy + dz * dz)
  local fuel = turtle.getFuelLevel()
  local needed = distance + 1

  if fuel < needed then
    rednet.send(id, "ERROR - Need more fuel", protocol)
    return
  end

  rednet.send(id, "Attempting to move to " .. posX .. ", " .. posY .. ", " .. posZ, protocol)

  -- Up / Down
  if dy ~= 0 then
    if dy > 0 then
      repeat
        if turtle.detectUp() then
          if dig then
            turtle.digUp()
          else
            rednet.send(id, "ERROR - Obstacle at " .. x .. ", " .. y + 1 .. ", " .. z, protocol)
            return
          end
        end
        turtle.up()
        y = y + 1
      until y == posY
    else
      repeat
        if turtle.detectDown() then
          if dig then
            turtle.digDown()
          else
            rednet.send(id, "ERROR - Obstacle at " .. x .. ", " .. y - 1 .. ", " .. z, protocol)
            return
          end
        end
        turtle.down()
        y = y - 1
      until y == posY
    end
  end

  -- North / South (z)
  if dz ~= 0 then
    if dz > 0 then
      facing = face("north", facing)
    else
      facing = face("south", facing)
    end
    repeat
      if turtle.detect() then
        if dig then
          turtle.dig()
        else
          rednet.send(id, "ERROR - Obstacle at " .. x - 1 .. ", " .. y .. ", " .. z, protocol)
          return
        end
      end
      turtle.forward()
      if facing == "north" then
        z = z - 1
      else
        z = z + 1
      end
    until z == posZ
  end

  -- East / West (x)
  if dx ~= 0 then
    if dx > 0 then
      facing = face("west", facing)
    else
      facing = face("east", facing)
    end
    repeat
      if turtle.detect() then
        if dig then
          turtle.dig()
        else
          rednet.send(id, "ERROR - Obstacle at " .. x .. ", " .. y .. ", " .. z - 1, protocol)
          return
        end
      end
      turtle.forward()
      if facing == "west" then
        x = x - 1
      else
        x = x + 1
      end
    until x == posX
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
    elseif message[1] == "stop" then
      rednet.send(id, "Stopping...", protocol)
      return
    elseif message[1] == "come" then
      if message[2] == "all" then
        rednet.send(id, "ERROR - Solo command", protocol)
        return
      end
      if not message[3] or not message[4] or not message[5] then
        rednet.send(id, "ERROR - Missing arguments", protocol)
        return
      end
      parallel.waitForAny(come(message[3], message[4], message[5], message[6]), receiveMessages)
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
