local Actor = script.Parent:GetActor() 

Actor:BindToMessage("Init", function(MS : ModuleScript?)
    -- do something?
    print("ClientVM Init")
end)
