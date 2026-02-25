-- Services
local Rep = game:GetService("ReplicatedStorage")
local RepFirst = game:GetService("ReplicatedFirst")

-- Requires
local DispatcherModule = require(Rep:WaitForChild("VMsDispatcher"))

-- Test

DispatcherModule.Init(RepFirst, "VMContainer", "VM")
local Dispatcher = DispatcherModule.new(4)