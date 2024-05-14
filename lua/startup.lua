-- [[SETTINGS]] --
textColor = colors.white

-- Menu
selectedItem = 1

-- Mining
rows = 3
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
        menu[action].action()
    elseif key == keys.a then
        selectedItem = 1
        menu[#menu].action()
    elseif key == keys.space then
        selectedItem = 1
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

-- [[MENUS]] --
mainMenu =  {
    [1] = {
        name = "Mine",
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
        name = "Rows",
        action = setRows,
    },
    [2] = {
        name = "Cols",
        action = setCols
    },
    [3] = {
        name = "Height",
        action = setHeight
    },
    [4] = {
        name = "Return",
        action = showMineMenu
    }
}

systemMenu = {
    [1] = {
        name = "Fuel",
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
        name = "Check",
        action = getFuelLevel
    },
    [3] = {
        name = "Return",
        action = showSystemMenu
    }
}

settingsMenu = {
    [1] = {
        name = "Label",
        action = showLabelingMenu,
    },
    [2] = {
        name = "Return",
        action = showSystemMenu
    }
}

labelingMenu = {
    [1] = {
        name = "Set",
        action = setLabel,
    },
    [2] = {
        name = "Remove",
        action = removeLabel
    },
    [3] = {
        name = "Return",
        action = showSettingsMenu
    }
}

-- [[MAIN]] --
showMainMenu()
