-- example usage:
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/FaithfulAC/Megaprojects/refs/heads/main/dump_metamethod_calls_from_heavy.lua"))(game, "__namecall", "ReplicatedFirst.ExampleScript", false[, "hello", 25, 3])

-- function preparation (for tables/functions and dumping their indexes/values, constants or upvalues)

local CrazyCharacters = {
	["0"] = "\0",
	["n"] = "\n",
	["t"] = "\t",
	["s"] = "\s",
	["r"] = "\r",
	["f"] = "\f"
}

local function ReturnSafeString(str)
	if _G.ByteStrings then
		return "\\" .. table.concat({string.byte(str, 1, #str)}, "\\")
	end

	local safe = ""

	for i = 1, #str do
		local subchar = string.sub(str, i, i)
		local byteint = string.byte(subchar)

		if byteint > 35 and byteint < 127 then
			safe ..= subchar
		else
			local stop = false

			for key, value in pairs(CrazyCharacters) do
				if value == subchar then
					safe ..= "\\" .. key
					stop = true
					break
				end
			end

			if stop then continue end
			safe ..= "\\" .. byteint
		end
	end

	return safe
end

local function GetPath(ins)
	local path = ""

	if ins.Parent == nil then
		return ins.Name
	end

	local ancestry = {}
	repeat
		table.insert(ancestry, (ancestry[#ancestry] or ins).Parent)
	until ancestry[#ancestry] == game;

	for i = (#ancestry), 1, -1 do
		if ancestry[i] == game then
			path = path .. "game"
		elseif ancestry[i+1] == game then
			path = path .. ":FindFirstChildOfClass(\"" .. ancestry[i].ClassName .. "\")"
		else
			path = path .. ":FindFirstChild(\"" .. ReturnSafeString(ancestry[i].Name) .. "\")"
		end
	end

	path = path .. ":FindFirstChild(\"" .. ReturnSafeString(ins.Name) .. "\")"
	return path
end

local function makeParams(num, isVararg)
	local params = ""
	for i = 1, num do
		params ..= "v" .. tostring(i) .. ", "
	end
	if isVararg then
		params ..= "..."
	else
		params = string.sub(params, 1, #params-2)
	end
	return params
end

local opentable, openfunction;
local recursivetblcount, recursivefnccount = 1, 1

-- function ripped from simplespy
local function u2s(u)
	if typeof(u) == "TweenInfo" then
		-- TweenInfo
		return "TweenInfo.new("
			.. tostring(u.Time)
			.. ", Enum.EasingStyle."
			.. tostring(u.EasingStyle)
			.. ", Enum.EasingDirection."
			.. tostring(u.EasingDirection)
			.. ", "
			.. tostring(u.RepeatCount)
			.. ", "
			.. tostring(u.Reverses)
			.. ", "
			.. tostring(u.DelayTime)
			.. ")"
	elseif typeof(u) == "Ray" then
		-- Ray
		return "Ray.new(" .. u2s(u.Origin) .. ", " .. u2s(u.Direction) .. ")"
	elseif typeof(u) == "NumberSequence" then
		-- NumberSequence
		local ret = "NumberSequence.new("
		for i, v in pairs(u.KeyPoints) do
			ret = ret .. tostring(v)
			if i < #u.Keypoints then
				ret = ret .. ", "
			end
		end
		return ret .. ")"
	elseif typeof(u) == "DockWidgetPluginGuiInfo" then
		-- DockWidgetPluginGuiInfo
		local stringedArgs = tostring(u)
		stringedArgs = string.gsub(stringedArgs, " ", ", ")
		stringedArgs = string.gsub(stringedArgs, "InitialDockState:", "Enum.InitialDockState.")
		stringedArgs = string.gsub(stringedArgs, "InitialEnabled:", "")
		stringedArgs = string.gsub(stringedArgs, "InitialEnabledShouldOverrideRestore:", "")
		stringedArgs = string.gsub(stringedArgs, ", 1", ", true")
		stringedArgs = string.gsub(stringedArgs, ", 0", ", false")
		for i, v in pairs({"FloatingXSize:", "FloatingYSize:", "MinWidth:", "MinHeight:"}) do
			stringedArgs = string.gsub(stringedArgs, v, "")
		end

		return "DockWidgetPluginGuiInfo.new(" .. stringedArgs .. ")"
	elseif typeof(u) == "ColorSequence" then
		-- ColorSequence
		local ret = "ColorSequence.new("
		for i, v in pairs(u.KeyPoints) do
			ret = ret .. "Color3.new(" .. tostring(v) .. ")"
			if i < #u.Keypoints then
				ret = ret .. ", "
			end
		end
		return ret .. ")"
	elseif typeof(u) == "BrickColor" then
		-- BrickColor
		return "BrickColor.new(" .. tostring(u.Number) .. ")"
	elseif typeof(u) == "NumberRange" then
		-- NumberRange
		return "NumberRange.new(" .. tostring(u.Min) .. ", " .. tostring(u.Max) .. ")"
	elseif typeof(u) == "Region3" then
		-- Region3
		local center = u.CFrame.Position
		local size = u.CFrame.Size
		local vector1 = center - size / 2
		local vector2 = center + size / 2
		return "Region3.new(" .. u2s(vector1) .. ", " .. u2s(vector2) .. ")"
	elseif typeof(u) == "Faces" then
		-- Faces
		local faces = {}
		if u.Top then
			table.insert(faces, "Enum.NormalId.Top")
		end
		if u.Bottom then
			table.insert(faces, "Enum.NormalId.Bottom")
		end
		if u.Left then
			table.insert(faces, "Enum.NormalId.Left")
		end
		if u.Right then
			table.insert(faces, "Enum.NormalId.Right")
		end
		if u.Back then
			table.insert(faces, "Enum.NormalId.Back")
		end
		if u.Front then
			table.insert(faces, "Enum.NormalId.Front")
		end
		return "Faces.new(" .. table.concat(faces, ", ") .. ")"
	elseif typeof(u) == "RBXScriptSignal" then
		return string.gsub(tostring(u), "Signal ", "") .. " --[[RBXScriptSignal]]"
	elseif typeof(u) == "PathWaypoint" then
		return string.format("PathWaypoint.new(%s, %s)", "Vector3.new(" .. tostring(u.Position) .. ")", tostring(u.Action))
	else
		if getrenv()[typeof(u)] and getrenv()[typeof(u)].new then
			return typeof(u) .. ".new(" .. tostring(u) .. ") --[[warning: not reliable]]"
		end
		return typeof(u) .. " --[[actual value is a userdata]]"
	end
end

local list = {
	Axes = Axes,
	buffer = buffer,
	bit32 = bit32,
	BrickColor = BrickColor,
	coroutine = coroutine,
	CFrame = CFrame,
	Color3 = Color3,
	ColorSequenceKeypoint = ColorSequenceKeypoint,
	ColorSequence = ColorSequence,
	Content = Content,
	CatalogSearchParams = CatalogSearchParams,
	debug = debug,
	DockWidgetPluginGuiInfo = DockWidgetPluginGuiInfo,
	DateTime = DateTime,
	Faces = Faces,
	FloatCurveKey = FloatCurveKey,
	Font = Font,
	Instance = Instance,
	math = math,
	NumberRange = NumberRange,
	NumberSequenceKeypoint = NumberSequenceKeypoint,
	NumberSequence = NumberSequence,
	OverlapParams = OverlapParams,
	os = os,
	PathWaypoint = PathWaypoint,
	PhysicalProperties = PhysicalProperties,
	Path2DControlPoint = Path2DControlPoint,
	Random = Random,
	Ray = Ray,
	RotationCurveKey = RotationCurveKey,
	Region3 = Region3,
	Region3int16 = Region3int16,
	Rect = Rect,
	RaycastParams = RaycastParams,
	string = string,
	SharedTable = SharedTable,
	SecurityCapabilities = SecurityCapabilities,
	task = task,
	table = table,
	TweenInfo = TweenInfo,
	UDim2 = UDim2,
	utf8 = utf8,
	UDim = UDim,
	Vector2 = Vector2,
	Vector3 = Vector3,
	Vector2int16 = Vector2int16,
	Vector3int16 = Vector3int16,
}

local function isInRobloxEnvTable(func)
	for i, v in pairs(list) do
		for i2, v2 in pairs(v) do
			if v2 == func then
				return i .. "."
			end
		end
	end
	return false
end

local function Safetostring(obj)
	if typeof(obj) == "nil" or typeof(obj) == "boolean" then
		return tostring(obj)
	end

	if typeof(obj) == "string" then
		return '"' .. ReturnSafeString(obj) .. '"' --[[gsub " bait later?]]
	end

	if typeof(obj) == "function" then
		-- TO RESOLVE AND DO OTHER STUFF WITH
		if iscclosure(obj) and (getrenv()[debug.info(obj, "n")] or isInRobloxEnvTable(obj)) then
			return isInRobloxEnvTable(obj) and isInRobloxEnvTable(obj) .. debug.info(obj, "n") or debug.info(obj, "n")
		elseif iscclosure(obj) then
			return "function()end --[[is a cclosure]]"
		end
		if recursivefnccount > 20 then
			return "--[[Recursive function depth exceeded max of 20]]"
		end
		return openfunction(obj, recursivefnccount)
	end

	if typeof(obj) == "thread" then
		return "coroutine.create(function()end) --[[" .. tostring(obj) .. "]]"
	end

	if typeof(obj) == "number" then
		return tostring(obj)
	end

	if typeof(obj) == "userdata" then
		if getmetatable(obj) then return "newproxy(true)" end
		return "newproxy()"
	end

	if typeof(obj) == "Instance" then
		return GetPath(obj) --[[if in nil, say: nil instance]]
	end

	if typeof(obj) == "table" then
		for i, v in pairs(list) do
			if v == obj then
				return i
			end
		end

		if recursivetblcount > 20 then
			return "--[[Table depth exceeded max of 20]]"
		end
		return opentable(obj, recursivetblcount)
	end

	if typeof(obj) == "Enums" then
		return "Enum"
	end

	if typeof(obj) == "Enum" then
		return "Enum." .. tostring(obj)
	end

	if typeof(obj) == "EnumItem" then
		return tostring(obj)
	end

	if typeof(obj) == "buffer" then
		local thing = buffer.tostring(obj)
		local len = buffer.len(obj)

		if len < 10000 and string.gsub(thing, "\0", "") ~= "" then
			return "buffer.fromstring(\"" .. ReturnSafeString(thing) .. "\")"
		elseif len >= 10000 and string.gsub(thing, "\0", "") ~= "" then
			return "buffer.fromstring(\"" .. ReturnSafeString(string.sub(thing, 1, 20)) .. " (...)\") --[[Exceeded max of 20 characters]]"
		end

		return "buffer.create(" .. len .. ")"
	end

	if type(obj) == "userdata" then --[[already looped thru other ud's]]
		return u2s(obj)
	end
end

opentable = function(tbl, tabcount)
	local tabcount = string.rep("\t", tabcount or 1)
	recursivetblcount += 1;
	local orgR;
	
	if #tabcount >= recursivetblcount then
		orgR = recursivetblcount
		recursivetblcount = #tabcount + 1
	end
	
	local str = "{\n"
	for i, v in pairs(tbl) do
		str ..= tabcount
		str ..= "[" .. Safetostring(i) .. "] = " .. Safetostring(v) .. ",\n"
	end
	str ..= string.rep("\t", recursivetblcount - 2) .. "}"
	
	if orgR then
		recursivetblcount = orgR
	else
		recursivetblcount -= 1;
	end
	return str
end

openfunction = function(func, tabcount)
	if not islclosure(func) then return Safetostring(func) end
	local tabcount = string.rep("\t", tabcount or 1)
	recursivefnccount += 1;
	local orgR;
	
	if #tabcount >= recursivefnccount then
		orgR = recursivefnccount
		recursivefnccount = #tabcount + 1
	end

	local str = "function(" .. makeParams(debug.info(func, "a")) .. ")\n" .. tabcount
	
	str ..= "Constants:\n"
	
	for i, v in pairs(getconstants(func)) do
		str ..= tabcount .. "\t" .. tostring(i) .. ": " .. Safetostring(v) .. "\n"
	end
	
	str ..= "\n" .. tabcount .. "Upvalues:\n"

	for i, v in pairs(getupvalues(func)) do
		str ..= tabcount .. "\t" .. tostring(i) .. ": " .. Safetostring(v) .. "\n"
	end
	
	str ..= string.rep("\t", recursivefnccount - 2) .. "end"

	if orgR then
		recursivefnccount = orgR
	else
		recursivefnccount -= 1;
	end
	return str
end

------------------------------------ where the true fun begins ------------------------------------

pcall(function()
	-- you better expect a shit ton of lag
	game:GetService("ScriptContext"):SetTimeout(10)
end)

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
		local stuff = "self: " .. safetostring((...)) .. "\n" .. metamethod .. " method: " .. getnamecallmethod() .. "\n\nCalling Functions:\n"

		for i = 1, getmaxstacklevel() do
			if not debug.info(i, "f") then stuff = "" break end
			if debug.info(i, "s") == expSrc then continue end
			stuff ..= "src: " .. debug.info(i, "s") .. "; n: "  .. debug.info(i, "n") .. "; a1: " .. tostring(debug.info(i, "a")) .. "; a2: "  .. tostring(select(2, debug.info(i, "a"))) .. "\n"
			local fnc = debug.info(i, "f")
			if islclosure(fnc) then
				stuff ..= openfunction(fnc)
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
