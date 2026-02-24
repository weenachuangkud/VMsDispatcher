--[[
	- Author : Mawin CK
	- Date : 11/03/2025
]]

-- Requires
local ClientVM = require(script.Parent:WaitForChild("ClientVMs"))

-- Test
local numWorker = 4
local dispatcher = ClientVM.new(4, nil)
