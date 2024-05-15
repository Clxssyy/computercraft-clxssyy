if not pocket then
  return
end

function receive(message, id)
  term.setTextColor(colors.lime)
  io.write("[" .. id .. "] ")
  term.setTextColor(textColor)
  print(message)
end

function error(message)
  term.setTextColor(colors.red)
  print("[!] " .. message)
  term.setTextColor(textColor)
end

function showHeader()
  term.clear()
  term.setCursorPos(1, 1)
  io.write("-----={ ")
  term.setTextColor(colors.lime)
  io.write("ClassyTerm")
  term.setTextColor(textColor)
  io.write(" }=-----\n")
end

function receiveMessages()
  while true do
    local id, message = rednet.receive(protocol)
    receive(message, id)
  end
end

function split(input, separator)
  local t = {}
  for str in string.gmatch(input, "([^" .. separator .. "]+)") do
    if str == "MYPOSITION" then
      local x, y, z = gps.locate()
      table.insert(t, x)
      table.insert(t, y)
      table.insert(t, z)
    else
      table.insert(t, str)
    end
  end
  return t
end

function sendMessages()
  local input = read()

  input = split(input, " ")

  -- [[Transmitter commands]]
  if not input[2] then
    if input[1] == "clear" then
      term.clear()
      term.setCursorPos(1, 1)
      showHeader()
      return
    elseif input[1] == "location" then
      local x, y, z = gps.locate()
      print("Location: " .. x .. ", " .. y .. ", " .. z)
      return
    else
      error("Usage: <message> <id> <args>")
      return
    end
  end

  -- [[Receiver commands]]
  if input[2] == "all" then -- Send to all computers with protocol
    rednet.broadcast(input, protocol)
    return
  else 
    local id = tonumber(input[2])

    if id == nil then -- Check if id is a number
      error("Invalid ID")
      return
    elseif not rednet.lookup(protocol, tostring(id)) then -- Check if id is a valid computer id
        error("ID not found")
      return
    end

    rednet.send(id, input, protocol)
    return
  end
end

function main()
  showHeader()

  while true do
    parallel.waitForAny(receiveMessages, sendMessages)
  end
end

textColor = colors.white
protocol = "secret"
rednet.open("back")

main()
