if turtle or pocket then
  return
end

-- [[GLOBAL VARIABLES]] --
textColor = colors.white
headerColor = colors.lime
protocol = "classy/train"
computerID = os.getComputerID()
rednet.open("right")
rednet.host(protocol, tostring(computerID))

station = peripheral.wrap("left")
stationName = station.getStationName()
monitor = peripheral.wrap("top")
monitorX, monitorY = monitor.getSize()

termX, termY = term.getSize()

command = {}
commandList = {}

selectedItem = 1

scheduleCreated = false
start = nil
destination = nil

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

-- takes a string and a separator and returns a table of strings
function split(input, separator)
  local t = {}
  for str in string.gmatch(input, "([^" .. separator .. "]+)") do
      table.insert(t, str)
  end
  return t
end

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
  if textLength % 2 == 0 then
    side = "-" .. side
  end
  print(string.reverse(side))
end

function displayMessage(message)
  if id then
    rednet.send(id, message, protocol)
  else
    term.setTextColor(headerColor)
    print("[+] " .. message)
    term.setTextColor(textColor)
  end
end

function displayGUI(menu, title)
  term.clear()
  term.setCursorPos(1, 1)

  -- [[HEADER]] --
  displayHeader(title)
  print("")

  -- [[ITEMS]] --
  for i = 1, #menu do
      if i == selectedItem then
          term.setTextColor(headerColor)
          print(">> " .. menu[i].name .. (menu[i].required == true and "*" or ""))
          term.setTextColor(textColor)
      else
          print("   " .. menu[i].name .. (menu[i].required == true and "*" or ""))
      end
  end

  -- [[FOOTER]] --
  print("\n")

  if term.getCursorPos() ~= termY- 1 then
    term.setCursorPos(1, termY - 1)
  end
  displayHeader("<A>    <C>    <D>")
end

function onKeyPressed(key, menu)
  if key == keys.w then
      selectedItem = math.max(1, selectedItem - 1)
  elseif key == keys.s then
      selectedItem = math.min(#menu, selectedItem + 1)
  elseif key == keys.d then
      action = selectedItem
      selectedItem = 1
      os.sleep(0.01)
      menu[action].action()
  elseif key == keys.a then
      selectedItem = 1
      os.sleep(0.01)
      menu[#menu].action()
  end
end

function confirmAction(message, action)
  io.write(message .. " (Y/N): ")
  local input = io.read()
  if input == "Y" or input == "y" then
    if action then
      action()
    end
  end
end

-- [[COMMANDS]] --
-- Monitor
function setMonitorText(text)
  if type(text) == "table" then
    local newText = ""
    for i = 1, #text do
      newText = newText .. text[i] .. " "
    end
    text = newText
  end

  monitor.clear()
  monitor.setCursorPos(1, 1)
  monitor.setTextColor(textColor)
  monitor.write(text)

  displayMessage("Monitor text set to: " .. text)
end

-- Station
scheduleGUI = {
  [1] = {
    name = "Destination",
    required = true,
    action = function()
      destination = io.read()
      confirmAction("Are you sure?")
    end
  },
  [2] = {
    name = "Finish",
    action = function()
      scheduleCreated = true
      clear()
    end
  }
}

function setSchedule(input)
  if station.isTrainPresent() == false then
    error("No train present")
    return
  end

  start = stationName
  destination = nil

  if id then
    rednet.send(id, {
      type = "input",
      message = "Enter destination",
    }, protocol)
    local senderID, senderMessage = rednet.receive(protocol)

    if senderMessage then
      destination = senderMessage
      scheduleCreated = true
    end
  end

  while not scheduleCreated do
    displayGUI(scheduleGUI, "Schedule")
    local event, key = os.pullEvent("key")
    onKeyPressed(key, scheduleGUI)
  end
  if not destination then
    error("No destination provided")
    return
  end
  station.setSchedule({
    cyclic = false, -- Does the schedule repeat itself after the end has been reached?
    entries = { -- List of entries, each entry contains a single instruction and multiple conditions.
      {
        instruction = {
          id = "create:destination", -- The different instructions are described below.
          data = { -- Data that is stored about the instruction. Different for each instruction type.
            text = destination,
          },
        },
        conditions = {    -- List of lists of conditions. The outer list is the "OR" list
          {               -- and the inner lists are "AND" lists.
            {
              id = "create:delay", -- The different conditions are described below.
              data = { -- Data that is stored about the condition. Different for each condition type.
                value = 5,
                time_unit = 1,
              },
            },
          },
        },
      },
    },
  })
  displayMessage("Schedule set")
  scheduleCreated = false
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

  if string.len(name .. " - " .. computerID) > termX then
    error("Name too long")
    return
  end

  station.setStationName(name)
  stationName = station.getStationName()
  clear()
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
  setMonitorText(stationName)
  term.clear()
  term.setCursorPos(1, 1)
  displayHeader(stationName)

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

function executeCommand(command, commandList)
  for i = 1, #commandList do
    if string.lower(command[1]) == commandList[i].name then -- Command found
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
  term.clear()
  term.setCursorPos(1, 1)
  displayHeader(stationName)

  while true do
    receiveCommands()
  end
end

setMonitorText(stationName)
main()