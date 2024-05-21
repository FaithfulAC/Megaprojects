--[[
    What is the goal of this script? To prevent almost any and almost all 
]]

local cloneref = cloneref or function(...) return ... end
local clonefunction = clonefunction or function(...) return ... end

local function GetService(class)
    return cloneref(game:FindFirstChildWhichIsA(class) or game:GetService(class))
end

local Players, Debris, ScriptContext = GetService("Players"), GetService("Debris"), GetService("ScriptContext")
local LocalPlayer = cloneref(Players.LocalPlayer)

local TotalNamecallHook;
local DestroyHook; -- Destroy and destroy
local RemoveHook; -- Remove and remove
local AddItemHook; -- AddItem and addItem
local KickHook; -- Kick only :)

ScriptContext:SetTimeout(1) -- Prevent while true-related crashes

-- TBC
