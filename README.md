# VMsDispatcher
Modded Dispatcher borrowed from SecureCast
> [!NOTE]
> I DID NOT OWN THIS MODULE, I JUST MODDED IT(a little)
> 
> THE ORIGINAL IS [HERE](https://github.com/1Axen/Secure-Cast/blob/main/src/Dispatcher/init.lua)


## What is this about?
Parallel scripting Module, aimed at making multi-threading for a lot of Actors easier 


# Getting started 

1. Creating a LocalScript or Script in any Folder/Container, and now copy and paste this
> (You can write your own; you don't need to  copy and paste)
```lua
-- Requires
local ClientVM = require(PathTo.VMsDispatcher)

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

3. Inside ClientVM/ServerVM, copy and paste this into :

```lua
local RS = game:GetService("RunService")

local Actor = script.Parent:GetActor()

Actor:BindToMessage("Init", function(MS : ModuleScript?)
	Actor:SetAttribute("Tasks", Actor:GetAttribute("Tasks")+1)
	RS.Heartbeat:ConnectParallel(function()
		debug.profilebegin("VMworker" .. tostring(math.random(1,100)))
		for i = 1, 10000 do
			i = i*i*i
		end
		debug.profileend()
	end)
end)
```

4. Enjoy/Test

- If you're doing this correctly, Open MicroProfiler `Ctrl+Window+F6`<br>
hover the mouse at some frame in the MicroProfiler, then `Ctrl+P`
Mess around to find something called "VMworker" and a Number, now it should look like this :
![Microprofiler1](https://github.com/weenachuangkud/VMsDispatcher/blob/main/pictures/microprofiler1)
> You can see the sample code I used and try to copy and paste it
> 
> if you're doing it correctly, you're gonna have 4 separated Threads like in this picture

## You can learn the API in the src
