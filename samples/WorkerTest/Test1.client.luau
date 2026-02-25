-- Services
local RepFirst = game:GetService("ReplicatedFirst")

-- Requires
local DispatcherModule = require(PathTo:WaitForChild("WorkerTestVMs"))

-- Test

DispatcherModule.Init(RepFirst, "VMContainer", "VM")
local Dispatcher = DispatcherModule.new(4)