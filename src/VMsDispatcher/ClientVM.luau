local Actor = script.Parent:GetActor() 

Actor:BindToMessage("Init", function(MS: ModuleScript?)
    print("ClientVM Init")
end)
