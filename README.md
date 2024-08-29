# ROBLOX IDL Compiler

A tool to make network coding easier in ROBLOX games.

## What it does

- Reads a simple format that describes data types
- Makes Luau code to send and receive data
- Works well with ROBLOX's network system
- Supports basic data types (numbers, text, true/false)

## How to use

1. Add the IDLCompiler script to your ROBLOX project
2. Write your data types in the simple format
3. Use the `compile` function to make the code

## Example

```lua
local IDLCompiler = require(script.Parent.IDLCompiler)

local types = [[
Player {name:string health:int32 position:float32}
Item {id:uint16 name:string}
]]

local code = IDLCompiler.compile(types)
print(code)
