--!strict

-- ******************************* --
-- 			AX3NX / AXEN		   --
-- ******************************* --

-- Modded by Mawin_CK
-- Desc : I make it more customizable and more easy to use

---- Services ----

local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")

---- Imports ----

---- Settings ----

local IS_SERVER = RunService:IsServer()

export type Dispatcher = typeof(setmetatable({}, {})) & {
	Data: any?,
	Threads: {Actor},
	Callback: (...any) -> (...any),

	Dispatch: (Dispatcher, ...any) -> (),
	Allocate: (Dispatcher, Threads: number) -> (),
}

local ServerScript : Script = nil
local LocalScript : LocalScript = script:FindFirstChild("WhileWorker")

local ClientContainerName = "WhileVMs" 
local ServerContainerName = ""

local ClientControllerName = "WhileWorker"
local ServerControllerName = "ServerWhileWorker"

local ClientContainerParent = script.Parent:FindFirstChild("VMs") -- Make a folder for this
local ServerContainerParent = ServerScriptService

local Client = true
local Server = false

local UseBindableEvent = false

---- Constants ----

local Dispatcher = {}
Dispatcher.__index = Dispatcher

local Template;
local Container: Folder;

local ControllerName = (IS_SERVER and ServerControllerName or ClientControllerName)
local ContainerName = (IS_SERVER and ServerContainerName or ClientContainerName)
local ContainerParent = (IS_SERVER and ServerContainerParent or ClientContainerParent)

---- Variables ----

---- Private Functions ----

---- Public Functions ----

function Dispatcher.new(Threads: number, Data : any?, Callback: (...any) -> (...any)): Dispatcher
	--assert(typeof(Module) == "Instance" and Module:IsA("ModuleScript"), "Invalid argument #1 to 'Dispatcher.new', module must be a module script.")
	assert(type(Threads) == "number" and Threads > 0, "Invalid argument #2 to 'Dispatcher.new', threads must be a positive integer.")

	local self: Dispatcher = setmetatable({
		Data = Data,
		Threads = {},
		Callback = Callback,
	} :: any, Dispatcher)

	--> Allocate initial threads
	self:Allocate(Threads)

	return self
end

function Dispatcher:Allocate(Threads: number)
	assert(type(Threads) == "number" and Threads > 0, "Invalid argument #2 to 'Dispatcher.new', threads must be a positive integer.")

	local Actors = {}

	--> Create actors
	for Index = 1, Threads do
		local Actor = Template:Clone()
		Actor.Parent = Container
		
		local controller = Actor:FindFirstChild(ControllerName)
		if controller then
			controller.Enabled = true
		end
		if Actor:FindFirstChild("Output") and self.Callback then
			Actor.Output.Event:Connect(self.Callback)
		end
		table.insert(Actors, Actor)
	end

	--> Allow actors to start
	RunService.PostSimulation:Wait()

	--> Initialize actors
	for Index, Actor in Actors do
		Actor:SendMessage("Init", self.Data)
	end

	--> Merge actors into threads
	table.move(Actors, 1, #Actors, #self.Threads + 1, self.Threads)
end

function Dispatcher:Dispatch(Message : string?, ...)
	local Threads: {Actor} = table.clone(self.Threads)
	table.sort(Threads, function(a: Actor, b: Actor)
		return (a:GetAttribute("Tasks") < b:GetAttribute("Tasks"))
	end)

	Threads[1]:SendMessage(Message or "Dispatch", ...)
end

---- Initialization ----

do
	if IS_SERVER and not Server or not Client then return end
	local Actor = Instance.new("Actor")
	Actor:SetAttribute("Tasks", 0)

	if UseBindableEvent then
		local Output = Instance.new("BindableEvent")
		Output.Name = "Output"
		Output.Parent = Actor
	end

	local Controller
	if IS_SERVER then
		Controller = ServerScript and ServerScript:Clone()
	else
		Controller = LocalScript and LocalScript:Clone()
	end

	assert(Controller, "Controller script not found or not valid")

	Controller.Name = ControllerName or "Controller"
	Controller.Parent = Actor
	Actor.Parent = script

	Template = Actor :: any
end

do
	if IS_SERVER and not Server or not Client then return end
	Container = Instance.new("Folder")
	Container.Name = ContainerName or "DISPATCHER_THREADS"
	Container.Parent = ContainerParent
end

---- Connections ----

return Dispatcher

