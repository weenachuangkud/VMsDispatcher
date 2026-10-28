# VMsDispatcher

Modified Dispatcher module based on Secure-Cast.

> [!NOTE] 
> The original version can be found here: 
> https://github.com/1Axen/Secure-Cast/blob/main/src/Dispatcher/init.luau

## What is this?

VMsDispatcher is a parallel scripting module designed to make multi-threading across multiple Actors easier and more manageable.

It abstracts Actor communication and workload distribution, allowing you to dispatch tasks across worker threads efficiently.

- Load balancing: Uses a "Tasks" attribute on each Actor to track workload and routes new tasks to the least busy worker.

- No dependency on **SharedTable** (when used correctly).

- Designed to be highly customizable, different implementations can be adapted to suit various system architectures and use cases.

### Integration

Take [FastCast2Parallel](github.com/weenachuangkud/FastCast2Parallel) as an example, there's specialized implementation called `FastCastVMs` is used as the template. Whenever `FastCastParallel:Init(numWorkers, ...)` is called, it clones the `FastCastVMs` template and initializes the required parallel actors dynamically.

This demonstrates how VMsDispatcher can be embedded inside larger systems and tailored to their architecture.

Read more: [FastCast2 — BaseCast.Init()](https://weenachuangkud.github.io/FastCast2/api/BaseCast#Init)

### Manual setup instruction

1. Open your place in Roblox Studio.
2. Insert a **ModuleScript** into `ReplicatedStorage` (or any container you prefer).
3. Rename it to `VMsDispatcher` or whatever you like.
4. Open the source files from this repo:
   - `src/VMsDispatcher/init.luau` — main module logic
   - `src/VMsDispatcher/ClientVM.client.luau` - client actor code
   - `src/VMsDispatcher/ServerVM.server.luau` - server actor code
5. Copy the contents into the corresponding scripts in Studio.

The module is now ready to `require()`.

---

# Getting Started

### 1. Create a Runner Script

Create a `LocalScript` or `Script` inside any container (Folder / Model).

Name it `VMrunner` (or any name you prefer).

You can write your own implementation, copying is optional.

```lua
-- Requires
local ClientVM = require(PathTo.VMsDispatcher)

-- Test
local numWorker = 4
local dispatcher = ClientVM.new(numWorker, nil)
```

### 2. Install VMsDispatcher

Your Explorer tree should look like this:

```
Container (Folder / Model)
│
├── VMsDispatcher (ModuleScript)
├── ClientVM (LocalScript)
└── ServerVM (Script)
```

> [!WARNING]
> `ClientVM` and `ServerVM` must be **disabled**, or they will not work properly.

### 3. Test Worker Script

Inside `ClientVM` or `ServerVM`, paste this test code:

```lua
local RS = game:GetService("RunService")
local Actor = script:GetActor()

if not Actor then return end

Actor:BindToMessage("Init", function(MS : ModuleScript?)
	Actor:SetAttribute("Tasks", Actor:GetAttribute("Tasks") + 1)

	RS.Heartbeat:ConnectParallel(function()
		debug.profilebegin("VMworker" .. tostring(math.random(1,100)))

		for i = 1, 10000 do
			i = i*i*i
		end

		debug.profileend()
	end)
end)
```

### 4. Dispatch Tasks

Inside `VMrunner`, add:

```lua
local message = "DOTASK"

while task.wait(0.1) do
	dispatcher:Dispatch(message)
end
```

### 5. Replace Worker Logic (load-balancing Example)

Inside `ClientVM` or `ServerVM`, replace the previous code with:

```lua
local RS = game:GetService("RunService")
local Actor = script:GetActor()

if not Actor then return end

local message = "DOTASK"
local AMOUNT_OF_WORK = 1000

Actor:BindToMessage(message, function()
	Actor:SetAttribute("Tasks", Actor:GetAttribute("Tasks") + 1)

	local i = 0
	local connection

	connection = RS.Heartbeat:ConnectParallel(function()
		i += 1

		if i == AMOUNT_OF_WORK then
			connection:Disconnect()
			connection = nil
			Actor:SetAttribute("Tasks", Actor:GetAttribute("Tasks") - 1)
		end
	end)
end)
```

### 6. Testing

If everything is set up correctly:

1. Open MicroProfiler with:  
   `Ctrl + Window + F6`
2. Hover over a frame.
3. Press `Ctrl + P`.

You should see multiple separated worker threads (e.g., 4 threads if `numWorker = 4`).

MicroProfiler reference image:  
[MicroProfiler](https://create.roblox.com/docs/studio/microprofiler)
