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

function sendMessages()
  local input = read()

  local message, id = input:match("(%S+)%s+(%S+)")
  if id then
    id = tonumber(id)
    if id == nil then
      error("Invalid ID")
      return
    end
    -- check if id is a valid computer id
    if not rednet.lookup(protocol, tostring(id)) then
      error("Invalid ID")
      return
    end
    rednet.send(id, message, protocol)
  else
    if input == "" then
      error("Invalid input")
      return
    end
    if input == "clear" then
      term.clear()
      term.setCursorPos(1, 1)
      showHeader()
      return
    end
    rednet.broadcast(input, protocol)
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
