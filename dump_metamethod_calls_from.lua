-- example usage:
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/FaithfulAC/Megaprojects/refs/heads/main/dump_metamethod_calls_from.lua"))(game, "__namecall", "ReplicatedFirst.ExampleScript", false[, "hello", 25, 3])

local self, metamethod, sourceToLookFor, writeIndividualFiles, folderName, stackLimit, duration = ...

if not europa then
	loadstring(game:HttpGet("https://raw.githubusercontent.com/FaithfulAC/Megaprojects/refs/heads/main/europa_library_wip.lua"))()
	repeat task.wait() until europa
end

if not (writefile and isfolder and makefolder and getconstants and getupvalues and hookmetamethod) then return error("get a better exploit", 2) end
if not pcall(getrawmetatable, self) then return error("come on provide a damn legit self you dunce", 2) end
if not metamethod then return error("come on provide a damn metamethod you dunce", 2) end
if not sourceToLookFor then return error("come on provide a damn source you dunce", 2) end
if not folderName then folderName = "hello" end
if not stackLimit then stackLimit = 200 + 1 end
if not duration then duration = 9e9 end
if not isfolder(folderName) then makefolder(folderName) end

local expSrc = debug.info(1, "s")
local toWrite = ""
local finished = false

local h; h = hookmetamethod(self, metamethod, function(...)
	local self = ...
	local method;
	if metamethod == "__namecall" then
		method = getnamecallmethod()
	else
		method = (safetostring(select(2, ...)))
	end

	if not checkcaller() and debug.info(getcallingfunction(), "s"):find(sourceToLookFor) and getmaxstacklevel() < stackLimit then
		local stuff = "self: " .. safetostring((...)) .. "\n" .. metamethod .. " method: " .. method .. "\n\nCalling Functions:\n"

		for i = 1, getmaxstacklevel() do
			if not debug.info(i, "f") then stuff = "" break end
			if debug.info(i, "s") == expSrc then continue end
			stuff ..= "src: " .. debug.info(i, "s") .. "; n: "  .. debug.info(i, "n") .. "; a1: " .. tostring(debug.info(i, "a")) .. "; a2: "  .. tostring(select(2, debug.info(i, "a"))) .. "\n"
			local fnc = debug.info(i, "f")
			if islclosure(fnc) then
				stuff ..= "\n> Constants:\n\n"
				for i, v in getconstants(fnc) do
					stuff ..= tostring(i) .. ": " .. safetostring(v) .. "\n"
				end
				stuff ..= "\n> Upvalues:\n\n"
				for i, v in getupvalues(fnc) do
					stuff ..= tostring(i) .. ": " .. safetostring(v) .. "\n"
				end
			end
		end

		if stuff == "" then return h(...) end
		stuff ..= "---------------------------------------\n"
		toWrite ..= stuff
		if writeIndividualFiles then
			writefile("hello/" .. tostring(game.PlaceId) .. "_" .. tostring(math.random(100, 1000000)) .. ".txt", stuff)
		end
	end

	return h(...)
end)

task.delay(duration, function()
	hookmetamethod(self, metamethod, h)
	finished = true
end)

task.spawn(function()
	while (not finished) and task.wait(1) do
		writefile(folderName .. "/_mainFor" .. tostring(game.PlaceId) .. ".txt", toWrite)
	end
end)
