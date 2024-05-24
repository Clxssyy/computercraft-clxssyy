-- [[Shopping Terminal]] --

-- Require currency to be deposited
-- Set currency
-- Allow user to select item
-- Check if item is in stock
-- Check if user has enough currency
-- Deduct currency
-- Dispense item
-- Return change

term.clear()
term.setCursorPos(1, 1)

shopName = "Shop"
if shopName == nil then
    print("Please set the shop name.")
    return
end

currency = ""
if currency == nil then
  -- Run currency setup
end

stock = peripheral.find("inventory")
if stock == nil then
  print("No inventory peripheral found.")
  return
end
items = stock.list()
inventory = {}

for slot, item in pairs(items) do
  details = stock.getItemDetail(slot)
  price = 0

  term.write(currency .. " per " .. details.displayName .. ": ")
  price = tonumber(io.read())

  inventory[slot] = {
    name = details.displayName,
    id = item.name,
    count = item.count,
    price = price
  }
end

term.clear()
term.setCursorPos(1, 1)

textColor = colors.white
headerColor = colors.yellow
selectedItem = 1

termX, termY = term.getSize()

cart = {}
total = 0

function onKeyPressed(key, menu)
  if key == keys.w then
      selectedItem = math.max(1, selectedItem - 1)
  elseif key == keys.s then
      selectedItem = math.min(#menu, selectedItem + 1)
  elseif key == keys.d then
      addToCart()
      os.sleep(0.01)
  elseif key == keys.a then
      removeFromCart()
      os.sleep(0.01)
  end
end

function displayHeader(text, bool)
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
  if bool then
    term.write(string.reverse(side))
  else
    print(string.reverse(side))
  end
end

function displayInventory(title)
  term.clear()
  term.setCursorPos(1, 1)
  displayHeader(title)
  print("")

  -- [[ITEMS]] --
  for slot, item in pairs(inventory) do
    if slot == selectedItem then
        term.setTextColor(colors.lime)
        term.write(">> ")
    else
        term.write("   ")
    end
    term.write(item.name .. " (" .. item.count .. ")")
    local termCX, termCY = term.getCursorPos()
    term.setCursorPos(termX - 1, termCY)
    term.write(item.price)
    term.setTextColor(textColor)
    print("")
  end

  print("")
  term.setCursorPos(termX, termY)
  term.setCursorPos(1, termY)
  displayHeader(total, true)
end

function showInventory()
  while true do
      displayInventory(shopName)
      event, key = os.pullEvent("key")
      onKeyPressed(key, inventory)
  end
end

function addToCart()
  local item = inventory[selectedItem]
  if item.count > 0 then
    if cart[item.id] == nil then
      cart[item.id] = {
        name = item.name,
        count = 1,
        price = item.price
      }
    else
      cart[item.id].count = cart[item.id].count + 1
    end
    item.count = item.count - 1
    total = total + item.price
  end
end

function removeFromCart()
  local item = inventory[selectedItem]
  if cart[item.id] ~= nil then
    if cart[item.id].count > 0 then
      cart[item.id].count = cart[item.id].count - 1
      item.count = item.count + 1
      total = total - item.price
    end
  end
end

function setupPeripherals()
  local peripherals = peripheral.getNames()
  -- select stock
  -- deposit box
end

showInventory()
