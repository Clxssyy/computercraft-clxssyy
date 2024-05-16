if turtle or pocket then
  return
end

-- [[GLOBAL VARIABLES]] --
textColor = colors.white
protocol = "classy/train"
computerID = os.getComputerID()
rednet.open("right")
rednet.host(protocol, tostring(computerID))

station = peripheral.wrap("left")
stationName = station.getStationName()
monitor = peripheral.wrap("top")
barrel = peripheral.wrap("back")

command = {}

-- [[UTILS]] --
function error(message)
  if id then
    rednet.send(id, "ERROR - " .. message, protocol)
  else
    term.setTextColor(colors.red)
    print("[!] " .. message)
    term.setTextColor(textColor)
  end
end

function split(input, separator)
  local t = {}
  for str in string.gmatch(input, "([^" .. separator .. "]+)") do
      table.insert(t, str)
  end
  return t
end

function displayHeader()
  term.clear()
  term.setCursorPos(1, 1)
  io.write("-----={ ")
  term.setTextColor(colors.lime)
  io.write(stationName .. " - " .. computerID)
  term.setTextColor(textColor)
  io.write(" }=-----\n")
end

function displayMessage(message)
  if id then
    rednet.send(id, message, protocol)
  else
    term.setTextColor(colors.lime)
    print("[+] " .. message)
    term.setTextColor(textColor)
  end
end

-- [[COMMANDS]] --
-- Monitor
function setMonitorText(text)
  if text then
    local newText = ""
    for i = 1, #text do
      if i == #text then
        newText = newText .. text[i]
        break
      end
      newText = newText .. text[i] .. " "
    end
    text = newText
  else
    text = stationName
  end

  monitor.clear()
  monitor.setCursorPos(1, 1)
  monitor.setTextColor(textColor)
  monitor.write(text)

  displayMessage("Monitor text set to: " .. text)
end

-- Station
function setSchedule(requestedSchedule)
  if not requestedSchedule then
    error("No schedule provided")
    return
  end

  local items = barrel.list()

  if #items == 0 then
    error("No items in barrel")
    return
  else
    for i = 1, #items do
      local item = barrel.getItemDetail(i)
      if item.name == "create:schedule" then
        if item.displayName == requestedSchedule then
          station.setSchedule(item)
        end
      end
    end
    error("Schedule not found")
  end
end

function setStationName(name)
  if name then
    local newName = ""
    for i = 1, #name do
      if i == #name then
        newName = newName .. name[i]
        break
      end
      newName = newName .. name[i] .. " "
    end
    name = newName
  else
    error("No name provided")
    return
  end

  station.setStationName(name)
  stationName = station.getStationName()
  displayMessage("Station name set to: " .. name)
end

function trainAssemble()
  if station.isInAssemblyMode() == false then
    error("Station is not in assembly mode")
    return
  end

  if pcall(station.assemble) == false then
    error("Missing train parts")
    return
  end
  displayMessage("Train assembled")
end

function toggleAssemblyMode()
  station.setAssemblyMode(not station.isInAssemblyMode())
  displayMessage("Assembly mode toggled")
end

function trainDisassemble()
  if station.isInAssemblyMode() == true then
    error("Station is in assembly mode")
    return
  end
  if pcall(station.disassemble) == false then
    error("No train to disassemble")
    return
  end
  displayMessage("Train disassembled")
end

function getTrainName()
  if station.isTrainPresent() == false then
    error("No train present")
    return
  end

  displayMessage("Train name: " .. station.getTrainName())
end

function getStationName()
  displayMessage("Station name: " .. stationName)
end

function setTrainName(name)
  if name then
    local newName = ""
    for i = 1, #name do
      if i == #name then
        newName = newName .. name[i]
        break
      end
      newName = newName .. name[i] .. " "
    end
    name = newName
  else
    error("No name provided")
    return
  end

  if station.isTrainPresent() == false then
    error("No train present")
    return
  end
  station.setTrainName(name)
  displayMessage("Train name set to: " .. name)
end

-- Utils
function clear()
  setMonitorText()
  term.clear()
  term.setCursorPos(1, 1)
  displayHeader()

  if id then
    rednet.send(id, "Screen cleared", protocol)
  end
end

registeredCommands = {
  [1] = {
    name = "clear",
    handler = clear
  },
  [2] = {
    name = "monitor",
    options = {
      [1] = {
        name = "set",
        options = {
          [1] = {
            name = "text",
            handler = setMonitorText
          }
        }
      },
    },
  },
  [3] = {
    name = "station",
    options = {
      [1] = {
        name = "set",
        options = {
          [1] = {
            name = "schedule",
            handler = setSchedule
          },
          [2] = {
            name = "name",
            handler = setStationName
          }
        }
      },
      [2] = {
        name = "assemble",
        handler = trainAssemble
      },
      [3] = {
        name = "toggle",
        handler = toggleAssemblyMode
      },
      [4] = {
        name = "disassemble",
        handler = trainDisassemble
      },
      [5] = {
        name = "get",
        options = {
          [1] = {
            name = "train",
            handler = getTrainName
          },
          [2] = {
            name = "name",
            handler = getStationName
          }
        }
      }
    }
  },
  [4] = {
    name = "train",
    options = {
      [1] = {
        name = "set",
        options = {
          [1] = {
            name = "name",
            handler = setTrainName
          }
        }
      },
      [2] = {
        name = "get",
        options = {
          [1] = {
            name = "name",
            handler = getTrainName
          }
        }
      }
    }
  }
}

commandList = {}

function executeCommand(command, commandList)
  for i = 1, #commandList do
    if command[1] == commandList[i].name then -- Command found
      if commandList[i].handler then -- Check for a handler
        if #command == 1 then -- Command has no arguments
          commandList[i].handler()
          return
        elseif #command > 1 and not commandList[i].options then -- Command has arguments
          table.remove(command, 1)
          commandList[i].handler(command)
          return
        end
      end
      if commandList[i].options then -- heck for options
        if #command == 1 then
          error("Usage error") -- No options provided
          return
        end

        commandList = commandList[i].options
        table.remove(command, 1)
        executeCommand(command, commandList)
        return
      end
    end
  end
  error("Command not found") -- Command not found
end

function receiveCommands()
  while true do
    id = nil
    parallel.waitForAny(
                        function()
                          id, input = rednet.receive(protocol)
                          table.remove(input, 2)
                          command = input
                        end,
                        function()
                          input = io.read()
                          local splitInput = split(input, " ")
                          command = splitInput
                        end
                      )

    executeCommand(command, registeredCommands)
  end
end

-- [[MAIN]] --
function main()
  displayHeader()

  while true do
    receiveCommands()
  end
end

setMonitorText()
main()