local Actor = script.Parent:GetActor() 

Actor:BindToMessage("Init", function()
    print("ClientVM Init")
end)
