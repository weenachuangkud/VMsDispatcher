local Actor = script.Parent:GetActor() 

Actor:BindToMessage("Init", function()
    print("ServerVM Init")
end)
