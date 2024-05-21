--[[
    What is the goal of this script? To prevent almost any and almost all (direct) methods of either destroying or kicking the player.
    This will not include methods that disconnect the client but do not do anything with the client, such as the Error Code 284 crasher.
    Of course, not everything remains undetected, especially with a script like this. If there is a flaw in logic, please do not hesitate to list it.

    Made by @__europa
    
]]
local SpoofedResult = (getgenv().Yield and function()
    return task.wait(9e9)
end) or function()
    return
end;

local cloneref = cloneref or function(...) return ... end
local clonefunction = clonefunction or function(...) return ... end

local function GetService(class)
    return cloneref(game:FindFirstChildWhichIsA(class) or game:GetService(class))
end

local Players, Debris, ScriptContext = GetService("Players"), GetService("Debris"), GetService("ScriptContext")
local LocalPlayer = cloneref(Players.LocalPlayer)

local GetDebugId, FindFirstChild = clonefunction(game.GetDebugId), clonefunction(game.FindFirstChild)

local compareinstances = function(ins1, ins2)
    return typeof(ins1) == "Instance" and typeof(ins2) == "Instance" and GetDebugId(ins1) == GetDebugId(ins2)
end

local TotalNamecallHook; -- Will include Destroy, Remove, AddItem and Kick call checks
local DestroyHook; -- Destroy and destroy
local RemoveHook; -- Remove and remove
local AddItemHook; -- AddItem and addItem
local KickHook; -- Kick only

ScriptContext:SetTimeout(1) -- Prevent while true-related crashes

TotalNamecallHook = hookmetamethod(game, "__namecall", function(...)
    local self, var = ...
    local method = getnamecallmethod()

    if not checkcaller() and typeof(self) == "Instance" then
        
    end
        
    return TotalNamecallHook(...)
end)

local DestroyDeter = function(...)
    local self = ...

    
    
    return DestroyHook(...)
end

local RemoveDeter = function(...)
    local self = ...

    

    return RemoveHook(...)
end

local AddItemDeter = function(...)
    local self, arg = ...

    
    
    return AddItemHook(...)
end

local KickDeter = function(...)
    local self, var = ...



    return KickHook(...)
end

DestroyHook = hookfunction(game.Destroy, DestroyDeter)
hookfunction(game.destroy, DestroyDeter)

RemoveHook = hookfunction(game.Remove, RemoveDeter)
hookfunction(game.remove, RemoveDeter)

AddItemHook = hookfunction(Debris.AddItem, AddItemDeter)
hookfunction(Debris.addItem, AddItemDeter)

KickHook = hookfunction(LocalPlayer.Kick, KickDeter)
-- TBC
