# VMsDispatcher

Modified Dispatcher module based on Secure-Cast.

> [!NOTE]
> I DO NOT OWN THIS MODULE.  
> I ONLY MODIFIED IT.  
> The original version can be found here:  
> https://github.com/1Axen/Secure-Cast/blob/main/src/Dispatcher/init.lua

---

## What is this?

VMsDispatcher is a parallel scripting module designed to make multi-threading across multiple Actors easier and more manageable.

It abstracts Actor communication and workload distribution, allowing you to dispatch tasks across worker threads efficiently.

---


# Getting Started

## 1. Create a Runner Script

Create a `LocalScript` or `Script` inside any container (Folder / Model).

Name it `VMrunner` (or any name you prefer).

You can write your own implementation — copying is optional.

```lua
-- Requires
local ClientVM = require(PathTo.VMsDispatcher)

-- Test
local numWorker = 4
local dispatcher = ClientVM.new(numWorker, nil)
```

---

2. Installing VMsDispatcher, the explorer tree should look like this :
<br>Container (any Folder / Model)<br>
│<br>
├── VMsDispatcher (ModuleScript)<br>
├──── ClientVM (LocalScript)<br>
└──── ServerVM (Script)<br>
> [!WARNING]
> ClientVM and ServerVM must be disabled, or they will not work

3. Inside ClientVM/ServerVM, copy and paste this into (For testing) :

```lua
local RS = game:GetService("RunService")

local Actor = script:GetActor()

if not Actor then return end

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

4. Want to dispatch?, Add these lines of code into the VMrunner :
```lua
local message = "DOTASK"
while task.wait(0.1) do
	dispatcher:Dispatch(message)
end
```

6. Inside ServerVM or ClientVM, replace with this :
```lua
local RS = game:GetService("RunService")

local Actor = script:GetActor()

if not Actor then return end

local message = "DOTASK"
local AMOUNT_OF_WORK = 1000

Actor:BindToMessage(message, function()
	Actor:SetAttribute("Tasks", Actor:GetAttribute("Tasks")+1)
	local i = 0
	local connection
	connection = RS.Heartbeat:ConnectParallel(function()
		-- some math idk :P
		i += 1
		if i == AMOUNT_OF_WORK then
			connection:Disconnect()
			connection = nil
			Actor:SetAttribute("Tasks", Actor:GetAttribute("Tasks")-1)
		end
	end)
end)
```

7. Enjoy/Test

- If you're doing this correctly, Open MicroProfiler `Ctrl+Window+F6`<br>
Hover the mouse at some frame in the MicroProfiler, then `Ctrl+P`
Mess around to find something, now it should look like this :
![Microprofiler1](https://github.com/weenachuangkud/VMsDispatcher/blob/main/pictures/microprofiler1)
> You can see the sample code I used and try to copy and paste it
> 
> If you're doing it correctly, you're gonna have 4 separated Threads like in this picture

# How is VMsDispatcher Used?

VMsDispatcher is used by FastCast2 to provide an API that allows users to easily allocate and manage threads through simple initialization.

It abstracts thread handling, making it easier for developers to distribute workloads without manually managing low-level threading logic.

(FastCast2 extends and modifies VMsDispatcher to integrate it with an initialization-driven API architecture)

For a usage example, see the repository:
https://github.com/weenachuangkud/FastCast2

You can learn the API in the src
