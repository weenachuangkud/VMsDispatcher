# VMsDispatcher
Modded Dispatcher borrowed from SecureCast


## What is this about?
Parallel scripting Module, aimed at making multi-threading for a lot of Actors easier 


# Getting started 

1. Creating a LocalScript or Script in any Folder/Container, and now copy and paste this
> (You can write your own; you don't need to  copy and paste)
```lua
-- Requires
local ClientVM = require(script.Parent:WaitForChild("VMsDispatcher"))

-- Test
local numWorker = 4
local dispatcher = ClientVM.new(numWorker, nil)
```

2. Installing VMsDispatcher, the explorer tree should look like this :
<br>Container (any Folder / Model)<br>
│<br>
├── VMsDispatcher (ModuleScript)<br>
├── ClientVM (LocalScript)<br>
└── ServerVM (Script)<br>
> [!WARNING]
> ClientVM and ServerVM must have Enabled = false, or will error

3. 
