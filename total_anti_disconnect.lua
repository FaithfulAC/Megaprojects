--[[
    What is the goal of this script? To prevent almost any and almost all (direct) methods of either destroying or kicking the player.
    This will not include methods that disconnect the client but do not do anything that directly calls a disconnect function, such as the Error Code 284 crasher.
    Of course, not everything remains undetected, especially with a script like this. If there is a flaw in logic, please do not hesitate to list it.

    Made by @__europa
    stupid indentation errors man
]]

-- TODO: add RemovePersistentPlayer (?)
local YieldThread = getgenv().Yield

local cloneref = cloneref or function(...) return ... end
local clonefunction = clonefunction or function(...) return ... end

local function GetService(class)
	return cloneref(game:FindFirstChildWhichIsA(class) or game:GetService(class))
end

local gsub, upper = string.gsub, stirng.upper;

local function CapitalizeFirstLetter(str)
	return gsub(str, "^%l", upper);
end

local Players, Debris, ScriptContext = GetService("Players"), GetService("Debris"), GetService("ScriptContext")
local LocalPlayer = cloneref(Players.LocalPlayer)

local GetDebugId, FindFirstChild = clonefunction(game.GetDebugId), clonefunction(game.FindFirstChild)

local compareinstances = function(ins1, ins2)
	return typeof(ins1) == "Instance" and typeof(ins2) == "Instance" and GetDebugId(ins1) == GetDebugId(ins2)
end

local function IsLegitimateKickMessage(var)
	return (pcall(FindFirstChild, game, var))
end

local TotalNamecallHook; -- Will include Destroy, Remove, AddItem and Kick call checks
local DestroyHook; -- Destroy and destroy
local RemoveHook; -- Remove and remove
local AddItemHook; -- AddItem and addItem
local KickHook; -- Kick only

ScriptContext:SetTimeout(3) -- Prevent while true-related crashes, just a little extra addition

TotalNamecallHook = hookmetamethod(game, "__namecall", function(...)
	local self, var, var2 = ...
	local method = CapitalizeFirstLetter(getnamecallmethod())

	if not checkcaller() and typeof(self) == "Instance" then
		if compareinstances(self, LocalPlayer) then
			if method == "Destroy" or method == "Remove" then
				return;
			elseif method == "Kick" and IsLegitimateKickMessage(var) then
				return;
			end
		elseif compareinstances(self, Debris) then
			if method == "AddItem" and compareinstances(var, LocalPlayer) and (typeof(var2) == "number" and var2 == var2 and var2 ~= 1/0) then
				return;
			end
		end
	end

	return TotalNamecallHook(...)
end)

local DestroyDeter = function(...)
	local self = ...

	if not checkcaller() and typeof(self) == "Instance" and compareinstances(self, LocalPlayer) then
		return;
	end

	return DestroyHook(...)
end

local RemoveDeter = function(...)
	local self = ...

	if not checkcaller() and typeof(self) == "Instance" and compareinstances(self, LocalPlayer) then
		return;
	end

	return RemoveHook(...)
end

local AddItemDeter = function(...)
	local self, var, var2 = ...

	if not checkcaller() and typeof(self) == "Instance" and compareinstances(self, Debris) then
		if compareinstances(var, LocalPlayer) and (typeof(var2) == "number" and var2 == var2 and var2 ~= 1/0) then
			return;
		end
	end

	return AddItemHook(...)
end

local KickDeter = function(...)
	local self, var = ...

	if not checkcaller() and typeof(self) == "Instance" and compareinstances(self, LocalPlayer) and IsLegitimateKickMessage(var) then
		return;
	end

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
