local Actor = script.Parent:GetActor() 

Actor:BindToMessage("Init", function(MS : ModuleScript?)
    -- do something?
    print("ServerVM Init")
end)
