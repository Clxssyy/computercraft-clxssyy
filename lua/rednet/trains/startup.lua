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

-- [[UTILS]] --
function error(message)
  term.setTextColor(colors.red)
  print("[!] " .. message)
  term.setTextColor(textColor)
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
  io.write("ClassyTrain - " .. computerID)
  term.setTextColor(textColor)
  io.write(" }=-----\n")
end

-- [[COMMANDS]] --
-- Monitor
function updateMonitor(text)
  if not text then
    text = stationName
  end

  monitor.clear()
  monitor.setCursorPos(1, 1)
  monitor.setTextColor(textColor)
  monitor.write(text)
end

-- Train
function setSchedule(requestedSchedule)
  local items = barrel.list()

  if #items == 0 then
    print("No items in barrel")
    return
  else
    for i = 1, #items do
      local item = barrel.getItemDetail(i)
      if item.name == "create:schedule" then
        if item.displayName == requestedSchedule then
          return item
        end
      end
    end
    print("Schedule not found")
  end
end

-- Utils
function clear()
  term.clear()
  term.setCursorPos(1, 1)
  displayHeader()
end

registeredCommands = {
  [1] = {
    name = "clear",
    action = clear
  }
}

function executeCommand(commandName)
  for i = 1, #registeredCommands do
    if registeredCommands[i].name == commandName then
      registeredCommands[i].action()
      return
    end
  end

  if id then
    rednet.send(id, "ERROR - Command not found", protocol)
  else
    error("Command not found")
  end
end

function receiveCommands()
  while true do
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

    executeCommand(command[1])
  end
end

-- [[MAIN]] --
function main()
  displayHeader()

  while true do
    receiveCommands()
  end
end

updateMonitor()
main()