local Actor = script.Parent:GetActor()

Actor:BindToMessage("Init", function(Data : any?)
	Actor:SetAttribute("Tasks", Actor:GetAttribute("Tasks")+1)
	task.desynchronize()
	while true do
		debug.profilebegin("Worker task" .. tostring(math.random(1,100)))
		for i = 1, 100000 do
			i = i*i*i
		end
		debug.profileend()
		task.wait()
	end
	task.synchronize()
	Actor:SetAttribute("Tasks", Actor:GetAttribute("Tasks")-1)
end)
