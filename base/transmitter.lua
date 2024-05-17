-- [[GLOBAL VARIABLES]] --
textColor = colors.white
receiveColor = colors.lime
headerColor = colors.blue
sendColor = headerColor

termX, termY = term.getSize()
computerID = os.getComputerID()

receiveSymbol = ">"
sendSymbol = "<"
systemCommandPrefix = "!"

protocol = "classy"
listenProtocol = protocol
sendProtocol = protocol
hostName = tostring(computerID)

computerLabel = os.setComputerLabel(hostName)

headerText = hostName

commands = {
  -- Set after defining the commands
}

variables = {

}

-- [[SETUP]] --
if pocket then
  rednet.open("back")
  rednet.host(protocol, hostName)
else
  rednet.open(peripheral.getName(peripheral.find("modem")))
  rednet.host(protocol, hostName)
end

-- [[UTILS]] --
-- handle received messages
function handleMessage(senderID, messageReceived, senderProtocol)
  if messageReceived.type == "message" then
    term.setTextColor(receiveColor)
    term.clearLine()
    local _, y = term.getCursorPos()
    term.setCursorPos(1, y)
    print("[" .. senderID .. "]" .. receiveSymbol .. " " .. messageReceived.message)
    term.setTextColor(textColor)
    return
  elseif messageReceived.type == "command" then
    term.clearLine()
    local _, y = term.getCursorPos()
    term.setCursorPos(1, y)
    term.setTextColor(textColor)
    executeCommand(messageReceived.command)
    return
  end
end

-- display error messages
function error(message)
  term.setTextColor(colors.red)
  print("[!] " .. message)
  term.setTextColor(textColor)
end

-- Turn a string into a table
-- TODO change name
function split(input, separator)
  local t = {}
  for str in string.gmatch(input, "([^" .. separator .. "]+)") do
    table.insert(t, str)
  end
  return t
end

-- Display the header
function displayHeader(text)
  local textLength = string.len(text) + 2
  local sideLength = math.floor((termX - textLength) / 2)
  local side = ""

  for i = 1, sideLength do
    if i == sideLength then
      side = side .. "|"
    elseif i == sideLength - 1 then
      side = side .. "="
    else
      side = side .. "-"
    end
  end

  io.write(side)
  term.setTextColor(headerColor)
  io.write(" " .. text .. " ")
  term.setTextColor(textColor)
  if textLength % 2 ~= 0 and termX % 2 == 0 or textLength % 2 == 0 and termX % 2 ~= 0 then
    side = "-" .. side
  end
  print(string.reverse(side))
end

-- [[COMMANDS]] --

-- [[REMOTE COMMANDS]] --
function message(input)
  local sentMessage = {
    type = "message",
    message = ""
  }
  local id

  if input[1] == "all" then
    id = "all"
  else
    id = tonumber(input[1])
  end
  table.remove(input, 1)

  for i = 1, #input do
    if i == #input then
      sentMessage.message = sentMessage.message .. input[i]
      break
    end
    sentMessage.message = sentMessage.message .. input[i] .. " "
  end

  if id == "all" then
    rednet.broadcast(sentMessage, sendProtocol)
  else
    rednet.send(id, sentMessage, sendProtocol)
  end
end

function run(input)
  local sentCommand = {
    type = "command",
    command = ""
  }

  if input[1] == "all" then
    error("Cannot send command to all computers")
    return
  end

  local id = tonumber(input[1])
  table.remove(input, 1)

  for i = 1, #input do
    if i == #input then
      sentCommand.command = sentCommand.command .. input[i]
      break
    end
    sentCommand.command = sentCommand.command .. input[i] .. " "
  end

  rednet.send(tonumber(id), sentCommand, sendProtocol)
end

commands = {
  ["system"] = {
    [1] = {
      name = "clear",
      description = "Clear the terminal",
      usage = "clear",
      handler = function()
        term.clear()
        term.setCursorPos(1, 1)
        term.setTextColor(textColor)
        displayHeader(headerText)
      end
    },
    [2] = {
      name = "help",
      description = "Display help",
      usage = "help <command>",
      handler = function(input)
        if not input[1] then
          error("Usage: help <command>")
          return
        end

        for commandIndex, command in pairs(commands["system"]) do
          if input[1] == command.name then
            term.setTextColor(colors.yellow)
            print("Name: " .. command.name)
            print("Description: " .. command.description)
            print("Usage: " .. command.usage)
            term.setTextColor(textColor)
            return
          end
        end
        error("Command not found")
      end
    }
  },
  ["remote"] = {
    [1] = {
      name = "message",
      description = "Send a message to a computer",
      usage = "message <id> <message>",
      handler = message
    },
    [2] = {
      name = "run",
      description = "Run a local command on a computer",
      usage = "run <id> <command>",
      handler = run
    }
  }
}

-- [[MAIN]] --
-- Listen for messages
function receiveMessages()
  while true do 
    local senderID, messageReceived, senderProtocol = rednet.receive(listenProtocol)
    handleMessage(senderID, messageReceived, senderProtocol)
    return
  end
end

function executeCommand(input)
  if type(input) == "table" and input[1]:sub(1, 1) == systemCommandPrefix then
    input[1] = input[1]:sub(2)
  else
    input = split(input, " ")
  end
  
  if input[1] == "" then
    error("No command entered")
    return
  else
    for commandIndex, command in pairs(commands["system"]) do
      if input[1] == command.name then
        table.remove(input, 1)
        command.handler(input)
        return
      end
    end
    error("Command not found")
    return
  end
end

function executeRemoteCommand(input)
  for commandIndex, command in pairs(commands["remote"]) do
    if input[1] == command.name then
      if not input[2] then
        error("No ID entered")
        return
      else
        local id = input[2]
        if id ~= "all" then
          id = tonumber(id)
          if id == nil then
            error("Invalid ID")
            return
          else
            local networkIDs = {rednet.lookup(protocol)}
            for networkIDIndex, networkID in pairs(networkIDs) do
              if networkID == id then
                if networkID == computerID then
                  error("Cannot send command to self")
                  return
                end
                found = true
                break
              end
            end
            if not found then
              error("ID not found")
              return
            end
          end
        end
        table.remove(input, 1)
        command.handler(input)
        return
      end
    end
  end
  error("Command not found")
end

-- Send messages
function sendMessages()
  local found = false
  local id = nil

  term.setTextColor(sendColor)
  io.write(sendSymbol .. " ")
  local input = io.read()
  input = split(input, " ")
  term.setTextColor(textColor)

  if not input[1] then
    return
  end

  if input[1]:find("^" .. systemCommandPrefix) then
    executeCommand(input)
  else
    executeRemoteCommand(input)
  end
end

-- Main function
-- Listen and send messages
function main()
  term.clear()
  term.setCursorPos(1, 1)
  displayHeader(headerText)

  while true do
    parallel.waitForAny(receiveMessages, sendMessages)
  end
end

main()
