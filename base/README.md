# Base Scripts

## Transmitter

- [ ] command options
- [ ] variables

### Commands

- no spaces in names
- no conflicting names
- inputs to functions are passed as a table
  - use verifyInput(input) if handler takes input
  ```lua
  if verifyInput(input) then
    -- your code
  end
  ```
  - use stringToTable() & tableToString() to swap between them easily
    - stringToTable() for single parameter
    - input[index] for multiple parameters

### Examples

#### Default System / Remote Commands

Shouldn't be removed, only added too with no conflicting names.

```lua
commands = {
  ["system"] = {
    {
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
    {
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
    {
      name = "message",
      description = "Send a message to a computer",
      usage = "message <id> <message>",
      handler = message
    },
    {
      name = "run",
      description = "Run a local command on a computer",
      usage = "run <id> <command>",
      handler = run
    }
  }
}
```

#### Added commands with options / suboptions

```lua
commands = {
  ["system"] = {
    {
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
    {
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
    },
    -- Add commands here
    {
      name = "name",
      description = "description",
      usage = "text to describe usage <usage>",
      -- handler = function() print("do something here") end,
      options = {
        {
          name = "optionName",
          description = "option description",
          usage = "option usage text",
          handler = function(input) tableToString(input, " ") print(input) end,
          options = {
            name = "subOptionName"
            description = "suboption description"
            usage = "suboption usage text"
            handler = function() print("something else") end
          }
        }
      }
    }
  },
  ["remote"] = {
    {
      name = "message",
      description = "Send a message to a computer",
      usage = "message <id> <message>",
      handler = message
    },
    {
      name = "run",
      description = "Run a local command on a computer",
      usage = "run <id> <command>",
      handler = run
    }
  }
}
```
