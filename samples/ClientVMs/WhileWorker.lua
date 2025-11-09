local Actor = script.Parent:GetActor()

Actor:BindToMessage("Init", function(MS : ModuleScript?)
	Actor:SetAttribute("Tasks", Actor:GetAttribute("Tasks")+1)
	task.desynchronize()
	while true do
		debug.profilebegin("WhileWorker" .. tostring(math.random(1,100)))
		for i = 1, 100000 do
			i = i*i*i
		end
		debug.profileend()
		task.wait()
	end
	task.synchronize()
	Actor:SetAttribute("Tasks", Actor:GetAttribute("Tasks")-1)
end)
