# Base Scripts

## Transmitter

- [ ] command options
- [ ] variables

### Commands

```lua
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
```
