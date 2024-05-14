-- [[SETTINGS]] --
textColor = colors.white

-- Menu
selectedItem = 1

-- Mining
rows = 1
cols = 3
height = 3

-- [[UTILS]] --
function error(message)
    term.setTextColor(colors.red)
    print("[!] " .. message)
    term.setTextColor(textColor)
end

function even(num)
    return num % 2 == 0
end

function printMenu(menu, title)
    term.clear()
    term.setCursorPos(1, 1)

    -- [[HEADER]] --
    term.setTextColor(textColor)
    io.write("---={ ")
    term.setTextColor(colors.lime)
    io.write("ClassyOS - " .. title)
    term.setTextColor(textColor)
    print(" }=---\n")

    -- [[ITEMS]] --
    for i = 1, #menu do
        if i == selectedItem then
            term.setTextColor(colors.lime)
            print(">> " .. menu[i].name .. (i == 1 and "*" or ""))
            term.setTextColor(textColor)
        else
            print("   " .. menu[i].name .. (i == 1 and "*" or ""))
        end
    end

    -- [[FOOTER]] --
    io.write("\n---={ ")
    term.setTextColor(colors.lime)
    io.write("<A>---<C>---<D>")
    term.setTextColor(textColor)
    print(" }=---")
end

function onKeyPressed(key, menu)
    if key == keys.w then
        selectedItem = math.max(1, selectedItem - 1)
    elseif key == keys.s then
        selectedItem = math.min(#menu, selectedItem + 1)
    elseif key == keys.d then
        action = selectedItem
        selectedItem = 1
        os.sleep(0.1)
        menu[action].action()
    elseif key == keys.a then
        selectedItem = 1
        os.sleep(0.1)
        menu[#menu].action()
    elseif key == keys.space then
        selectedItem = 1
        os.sleep(0.1)
        menu[1].action()
    end
end

-- [[PAGES]] --
function showMineMenu()
    while true do
        printMenu(mineMenu, "Mining")
        event, key = os.pullEvent("key")
        onKeyPressed(key, mineMenu)
    end
end

function showMainMenu()
    while true do
        printMenu(mainMenu, "Menu")

        event, key = os.pullEvent("key")
        onKeyPressed(key, mainMenu)
    end
end

function showSystemMenu()
    while true do
        printMenu(systemMenu, "System")

        event, key = os.pullEvent("key")
        onKeyPressed(key, systemMenu)
    end
end

function showMineConfigMenu()
    while true do
        printMenu(mineConfigMenu, "Mining Config")

        event, key = os.pullEvent("key")
        onKeyPressed(key, mineConfigMenu)
    end
end

function showFuelingMenu()
    while true do
        printMenu(fuelingMenu, "Fueling")

        event, key = os.pullEvent("key")
        onKeyPressed(key, fuelingMenu)
    end
end

function showSettingsMenu()
    while true do
        printMenu(settingsMenu, "Settings")

        event, key = os.pullEvent("key")
        onKeyPressed(key, settingsMenu)
    end
end

function showLabelingMenu()
    while true do
        printMenu(labelingMenu, "Labeling")

        event, key = os.pullEvent("key")
        onKeyPressed(key, labelingMenu)
    end
end

-- [[ACTIONS]] --
function mine()
    term.clear()
    term.setCursorPos(1, 1)

    print("Mining started\n\z
           Rows: " .. rows .. "\n\z
           Cols: " .. cols .. "\n\z
           Height: " .. height .. "\n\z")

    for y = 1, height do
        for z = 1, cols do
            for x = 1, rows - 1 do
                if turtle.detect() then
                    turtle.dig()
                end
                turtle.forward()
            end
            if z == cols then break end -- Prevents movement on last column

            if even(y) and even(cols) then
                if not even(z) then
                    turtle.turnLeft()
                    if turtle.detect() then
                        turtle.dig()
                    end
                    turtle.forward()
                    turtle.turnLeft()
                else
                    turtle.turnRight()
                    if turtle.detect() then
                        turtle.dig()
                    end
                    turtle.forward()
                    turtle.turnRight()
                end
            else
                if even(z) then
                    turtle.turnLeft()
                    if turtle.detect() then
                        turtle.dig()
                    end
                    turtle.forward()
                    turtle.turnLeft()
                else
                    turtle.turnRight()
                    if turtle.detect() then
                        turtle.dig()
                    end
                    turtle.forward()
                    turtle.turnRight()
                end
            end
        end
        if y == height then break end -- Prevents movement on last height

        if turtle.detectDown() then
            turtle.digDown()
        end
        turtle.down()
        turtle.turnRight()
        turtle.turnRight()
    end
end

function setRows()
    term.clear()
    term.setCursorPos(1, 1)

    io.write("---={ ")
    term.setTextColor(colors.lime)
    io.write("Set Rows")
    term.setTextColor(textColor)
    print(" }=---\n")
    io.write("Current: ")
    term.setTextColor(colors.lime)
    print(rows)
    term.setTextColor(textColor)
    io.write("New: ")
    term.setTextColor(colors.yellow)
    local newRows = tonumber(io.read())

    if newRows == nil then
        error("Rows must be a number")
        io.read()
        return
    end
    if newRows < 1 then
        error("Rows must be greater than 0")
    end

    rows = newRows

    term.setTextColor(textColor)
    io.read()
end

function setCols()
    term.clear()
    term.setCursorPos(1, 1)

    io.write("---={ ")
    term.setTextColor(colors.lime)
    io.write("Set Cols")
    term.setTextColor(textColor)
    print(" }=---\n")
    io.write("Current: ")
    term.setTextColor(colors.lime)
    print(cols)
    term.setTextColor(textColor)
    io.write("New: ")
    term.setTextColor(colors.yellow)
    local newCols = tonumber(io.read())

    if newCols == nil then
        error("Cols must be a number")
        io.read()
        return
    end
    if newCols < 1 then
        error("Cols must be greater than 0")
    end

    cols = newCols

    term.setTextColor(textColor)
    io.read()
end

function setHeight()
    term.clear()
    term.setCursorPos(1, 1)

    io.write("---={ ")
    term.setTextColor(colors.lime)
    io.write("Set Height")
    term.setTextColor(textColor)
    print(" }=---\n")
    io.write("Current: ")
    term.setTextColor(colors.lime)
    print(height)
    term.setTextColor(textColor)
    io.write("New: ")
    term.setTextColor(colors.yellow)
    local newHeight = tonumber(io.read())

    if newHeight == nil then
        error("Height must be a number")
        io.read()
        return
    end
    if newHeight < 1 then
        error("Height must be greater than 0")
    end

    height = newHeight

    term.setTextColor(textColor)
    io.read()
end

function refuel()
    term.clear()
    term.setCursorPos(1, 1)

    print("Refueling...")

    for i = 1, 16 do
        turtle.select(i)
        if turtle.refuel(0) then
            print("Refueled with " .. turtle.getItemCount(i) .. " " .. turtle.getItemDetail(i).displayName)
            turtle.refuel()
            print("Fuel level: " .. turtle.getFuelLevel())
            io.read()
            return
        end
    end

    error("No fuel found")
    io.read()
end

function getFuelLevel()
    term.clear()
    term.setCursorPos(1, 1)

    print("Fuel level: " .. turtle.getFuelLevel())
    io.read()
end

function setLabel()
    term.clear()
    term.setCursorPos(1, 1)

    io.write("---={ ")
    term.setTextColor(colors.lime)
    io.write("Set Label")
    term.setTextColor(textColor)
    print(" }=---\n")
    io.write("Current: ")
    term.setTextColor(colors.lime)
    print(os.getComputerLabel() or "None")
    term.setTextColor(textColor)
    io.write("New: ")
    term.setTextColor(colors.yellow)
    local newLabel = io.read()

    os.setComputerLabel(newLabel)

    term.setTextColor(textColor)
    io.read()
end

function removeLabel()
    term.clear()
    term.setCursorPos(1, 1)

    io.write("---={ ")
    term.setTextColor(colors.lime)
    io.write("Remove Label")
    term.setTextColor(textColor)
    print(" }=---\n")
    io.write("Current: ")
    term.setTextColor(colors.lime)
    print(os.getComputerLabel() or "None")
    term.setTextColor(textColor)
    if os.getComputerLabel() == nil then
        error("No label found")
        io.read()
        return
    end
    io.write("Remove? (y/n): ")
    term.setTextColor(colors.yellow)
    local remove = io.read()

    if remove == "y" then
        os.setComputerLabel(nil)
    end

    term.setTextColor(textColor)
    io.read()
end

-- [[MENUS]] --
mainMenu =  {
    [1] = {
        name = "Mining",
        action = showMineMenu,
    },
    [2] = {
        name = "System",
        action = showSystemMenu
    },
    [3] = {
        name = "Return",
        action = showMainMenu
    }
}

mineMenu = {
    [1] = {
        name = "Start",
        action = mine,
    },
    [2] = {
        name = "Config",
        action = showMineConfigMenu
    },
    [3] = {
        name = "Return",
        action = showMainMenu
    }
}

mineConfigMenu = {
    [1] = {
        name = "Set Rows",
        action = setRows,
    },
    [2] = {
        name = "Set Cols",
        action = setCols
    },
    [3] = {
        name = "Set Height",
        action = setHeight
    },
    [4] = {
        name = "Return",
        action = showMineMenu
    }
}

systemMenu = {
    [1] = {
        name = "Fueling",
        action = showFuelingMenu,
    },
    [2] = {
        name = "Settings",
        action = showSettingsMenu
    },
    [3] = {
        name = "Return",
        action = showMainMenu
    }
}

fuelingMenu = {
    [1] = {
        name = "Refuel",
        action = refuel,
    },
    [2] = {
        name = "Check Fuel",
        action = getFuelLevel
    },
    [3] = {
        name = "Return",
        action = showSystemMenu
    }
}

settingsMenu = {
    [1] = {
        name = "Labeling",
        action = showLabelingMenu,
    },
    [2] = {
        name = "Return",
        action = showSystemMenu
    }
}

labelingMenu = {
    [1] = {
        name = "Set Label",
        action = setLabel,
    },
    [2] = {
        name = "Remove Label",
        action = removeLabel
    },
    [3] = {
        name = "Return",
        action = showSettingsMenu
    }
}

-- [[MAIN]] --
showMainMenu()
