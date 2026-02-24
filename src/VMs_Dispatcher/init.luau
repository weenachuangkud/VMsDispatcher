-- ******************************* --
-- 			AX3NX / AXEN		   --
-- ******************************* --

-- Modded by Mawin_CK
-- Desc : I make it more customizable and more easy to use :P

-- Services --

local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")

-- Types --

local IS_SERVER = RunService:IsServer()

export type Dispatcher = {
	Init : (ContainerParent : Instance, VMContainerName : string, VMname : string) -> (),
	new : (Threads: number, Data: any?, Callback: (...any) -> (...any)?) -> Dispatcher,

	TemplateScript : LocalScript | Script,
	Data : any?,
	Threads: {Actor},
	Callback: (...any) -> (...any),

	Dispatch: (Dispatcher, Message : string?, ...any) -> (),
	Allocate: (Dispatcher, Threads: number, Data: any?, Callback: (...any) -> ()?) -> (),
	DispatchAll: (Dispatcher, Message : string?, ...any) -> (),

	Destroy : (Dispatcher) -> ()
}

-- Paths

local ServerScript : Script = script:FindFirstChild("ServerVM")

local LocalScript : LocalScript = script:FindFirstChild("ClientVM")

--- Default settings ---

local ClientContainerParent = ReplicatedFirst
local ServerContainerParent = ServerScriptService

-- Constants --

local Dispatcher = {}
Dispatcher.__index = Dispatcher
Dispatcher.__type = "Dispatcher"

local Template;
local Container;

local ControllerName = ""
local ContainerName = ""
local ContainerParent = (IS_SERVER and ServerContainerParent or ClientContainerParent)

-- Variables --

local AlreadyInit = false


-- Private Functions --


-- Public Functions --

--[[
	<p>
	Initialize the dispatcher
	
	NOTE : Only once in a client/server
	
	<strong>Parameters</strong> :
		- ContainerParent : The parent of the VM container
		- VMContainerName : The name of the VM container
		- VMContainer : The VM container
		- VMname : The name of the VM
	</p>
]]
function Dispatcher.Init(ContainerParent : Instance, VMContainerName : string, VMname : string)
	if AlreadyInit then 
		warn("Dispatcher already initialized")
		return 
	end

	-- Init

	local Actor = Instance.new("Actor")
	Actor:SetAttribute("Tasks", 0)		

	local Controller
	if IS_SERVER then
		Controller = ServerScript and ServerScript:Clone()
	else
		Controller = LocalScript and LocalScript:Clone()
	end

	-- Setup

	ControllerName = VMname
	ContainerName = VMContainerName
	ContainerParent = ContainerParent


	-- Start

	assert(Controller, "Controller script not found or not valid")

	Controller.Name = ControllerName or "Controller"
	Controller.Parent = Actor
	Actor.Parent = script

	Template = Actor :: any

	Container = Instance.new("Folder")
	Container.Name = ContainerName or "DISPATCHER_THREADS"
	Container.Parent = ContainerParent

	AlreadyInit = true
end


--[[
	Create a new dispatcher that can be used to dispatch messages to the actors
	
	<p><strong>Parameters</strong> : 
		Threads: number - The number of threads to use
		Module: ModuleScript? - The module to use for the actors
		Callback: (...any) -> (...any) - The callback to use for the actors
		
	Example :
		local dispatcher = Dispatcher.new(10, ModuleScript, function(...)
			print(...)
		end)
	</p>
	
	@return Dispatcher
]]
function Dispatcher.new(Threads: number, Data : any?, Callback: (...any) -> ()?): Dispatcher
	--assert(typeof(Module) == "Instance" and Module:IsA("ModuleScript"), "Invalid argument #1 to 'Dispatcher.new', module must be a module script.")
	assert(type(Threads) == "number" and Threads > 0, "Invalid argument #2 to 'Dispatcher.new', threads must be a positive integer.")

	if not AlreadyInit then
		error("Please Init dispatcher, RunContext : " .. IS_SERVER and "Server"or "Client")
	end


	local self: Dispatcher = setmetatable({
		Threads = {}
	} :: any, Dispatcher)

	--> Allocate initial threads
	self:Allocate(Threads, Data)

	return self
end

function Dispatcher:Allocate(Threads: number, Data: any?, Callback: (...any) -> (...any)?)
	assert(type(Threads) == "number" and Threads > 0, "Invalid argument #2 to 'Dispatcher.new', threads must be a positive integer.")

	local Actors = {}

	--> Create actors
	for Index = 1, Threads do
		local Actor = Template:Clone()
		Actor.Parent = Container

		local controller = Actor:FindFirstChild(ControllerName)
		
		if Callback then
			local Output = Instance.new("BindableEvent")
			Output.Name = "Output"
			Output.Parent = Actor

			Actor.Output.Event:Connect(self.Callback)
		end
		
		if controller then
			controller.Enabled = true
		end
		table.insert(Actors, Actor)
	end

	--> Allow actors to start
	RunService.PostSimulation:Wait()

	--> Initialize actors
	for Index, Actor in Actors do
		Actor:SendMessage("Init", Data)
	end

	--> Merge actors into threads
	table.move(Actors, 1, #Actors, #self.Threads + 1, self.Threads)
end

--[[
	Dispatch a message to the actors
	
	<p><strong>Parameters</strong> : 
		Message: string? - The message to send to the actors
		...: any - The arguments to send to the actors
		
		<strong>if the Message is nil, then the actors will be called with the "Dispatch" message</strong>
		
		Example : 
	
		local dispatcher = Dispatcher.new(10, nil)
		dispatcher:Dispatch("Hello from client", "Hello from client")
	</p>
]]
function Dispatcher:Dispatch(Message : string?, ...)
	local Threads: {Actor} = table.clone(self.Threads)
	table.sort(Threads, function(a: Actor, b: Actor)
		return (a:GetAttribute("Tasks") < b:GetAttribute("Tasks"))
	end)
	Threads[1]:SendMessage(Message or "Dispatch", ...)
end

function Dispatcher:Destroy(destroySource: boolean)
	for Index, Thread in self.Threads do
		Thread:SendMessage("Destroy")
	end
	self.Threads = {}

	task.spawn(function()
		while #Container:GetChildren() ~= 0 do task.wait() end
		Container:Destroy()
		if destroySource then
			script:Destroy()
		end
	end)
end

function Dispatcher:DispatchAll(Message : string?, ...)
	for Index, Thread in self.Threads do
		Thread:SendMessage(Message or "Dispatch", ...)
	end
end


return Dispatcher