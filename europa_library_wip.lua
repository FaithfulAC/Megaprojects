-- for std::string stuff

local clonefunction = clonefunction or function(...) return ... end
local cloneref = cloneref or function(...) return ... end

local GetFullName = clonefunction(game.GetFullName)
local GetDebugId = clonefunction(game.GetDebugId)
local FindFirstChild = clonefunction(game.FindFirstChild)

repeat task.wait() until game:IsLoaded() and game:GetService("Players").LocalPlayer

local europa = {
	Players = cloneref(game:GetService("Players")),
	LocalPlayer = cloneref(game:GetService("Players").LocalPlayer),
	hookfunc = hookfunction,

	getcharacter = function()
		local LocalPlayer = LocalPlayer or game:GetService("Players").LocalPlayer
		return (LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()) 
	end,

	gethumanoid = function()
		if getcharacter then
			local char = getcharacter()

			return char:FindFirstChildWhichIsA("Humanoid") or char:WaitForChild("Humanoid")
		else
			return game:GetService("Players").LocalPlayer and (game:GetService("Players").LocalPlayer.Character or game:GetService("Players").LocalPlayer.CharacterAdded:Wait())
				and game:GetService("Players").LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid") or game:GetService("Players").LocalPlayer.Character:WaitForChild("Humanoid")
		end
	end,

	HasCoreGuiPerms = function()
		return (pcall(function() GetFullName(game:GetService("CoreGui")) end))
	end,

	FindFirstDataModelDescendantWithDebugId = function(debugid: string)
		for i, v in pairs(game:GetDescendants()) do
			if GetDebugId(v) == debugid then
				return v
			end
		end
		return nil
	end,

	FindFirstDataModelDescendantOfClass = function(class: string)
		for i, v in pairs(game:GetDescendants()) do
			if v.ClassName == class then
				return v
			end
		end
		return nil
	end,

	FindFirstNilDescendantWithDebugId = function(debugid: string)
		for i, v in pairs(getnilinstances()) do
			if GetDebugId(v) == debugid then
				return v
			end
		end
		return nil
	end,

	FindFirstNilDescendantOfClass = if not getnilinstances then nil else function(class: string) -- this excludes datamodel for nil instances
		for i, v in pairs(getnilinstances()) do
			if v.ClassName == class then
				return v
			end
		end
		return nil
	end,

	TypeCheck = function(tbl, _type)
		for i, v in pairs(tbl) do
			if type(v) ~= _type then
				return false
			end
		end

		return true
	end,

	TypeofCheck = function(tbl, _type)
		for i, v in pairs(tbl) do
			if typeof(v) ~= _type then
				return false
			end
		end

		return true
	end,

	loadsafehookmetamethod = function(KeepOriginalFunction: boolean)
		getgenv().KeepHookmetamethod = KeepOriginalFunction
		loadstring(game:HttpGet("https://raw.githubusercontent.com/FaithfulAC/universal-stuff/main/safehookmetamethod.lua"))()
	end,

	loadonsignalconnected = function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/FaithfulAC/universal-stuff/main/on-signal-connected.lua"))()
	end,

	loadgetproperties = function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/FaithfulAC/universal-stuff/main/lua-getproperties.lua"))()
	end,

	firesignal = firesignal or function(conn,...)
		return (type(conn.Function) == "function" and conn.Function(...)) or error("Passed value is not a RBXScriptConnection")
	end,

	firetouchinterest = firetouchinterest or function(part, opart, numtype)
		if numtype == 1 then
			return nil; -- this fti implementation will only operate on 0 because it already does a TouchEnded firing
		end
		-- getconnections implementation or touchinterest parenting implementation

		if getconnections then
			for i, v in next, getconnections(opart.Touched) do
				firesignal(v, part)
			end

			for i, v in next, getconnections(opart.TouchEnded) do
				firesignal(v, part)
			end
		else
			local garbage = Instance.new("Part", workspace)

			garbage.Transparency, garbage.CanCollide, garbage.Anchored, garbage.Size = 1, false, true, Vector3.new(1,1,1)
			garbage.Name = math.random() -- auto tostring so doesnt matter :sunglasses:

			local interest = opart:FindFirstChildWhichIsA("TouchInterest")
			if interest then
				-- touchinterest thing
				interest.Parent = garbage.Parent
				for i = 1, 3 do
					garbage.CFrame = part.CFrame
				end

				task.wait()
				interest.Parent = opart.Parent
				garbage:Destroy()
			else
				-- force cframe to part
				local org = opart.CFrame
				for i = 1, 10 do
					opart.CFrame = part.CFrame
				end

				for i = 1, 1000 do end
				opart.CFrame = org
			end
		end
	end,

	fireproximityprompt = fireproximityprompt or function(Obj, Amount, Skip)
		-- ty reddit (https://www.reddit.com/r/ROBLOXExploiting/comments/tozlok/manipluating_proximity_prompts/)
		if Obj.ClassName == "ProximityPrompt" then
			Amount = Amount or 1
			local PromptTime = Obj.HoldDuration

			local PropertyChanged;
			if Skip then
				Obj.HoldDuration = 0.01
				PropertyChanged = Obj:GetPropertyChangedSignal("HoldDuration"):Connect(function()
					Obj.HoldDuration = 0.01
				end)
			end

			for i = 1, Amount do
				Obj:InputHoldBegin()
				task.wait(Obj.HoldDuration)
				Obj:InputHoldEnd()
			end

			if PropertyChanged then
				PropertyChanged:Disconnect()
				PropertyChanged = nil
			end
			Obj.HoldDuration = PromptTime
		else
			error("userdata<ProximityPrompt> expected", 0)
		end
	end,

	replacehookmetamethod = function(useHookFunction: boolean)
		if useHookFunction and hookfunction then
			getgenv().hookmetamethod = function(...)
				local object, metamethod, func = ...
				if type(func) == "function" and islclosure(func) then
					func = newcclosure(func)
				end

				local meta = (pcall(getrawmetatable, object) and getrawmetatable(object)) or error("Passed value has no valid rawmetatable")
				local orgmetamethod = meta[metamethod]

				hookfunction(orgmetamethod, func)
				return orgmetamethod
			end
		else
			getgenv().hookmetamethod = function(...)
				local object, metamethod, func = ...
				if type(func) == "function" and islclosure(func) then
					func = newcclosure(func)
				end

				local meta = (pcall(getrawmetatable, object) and getrawmetatable(object)) or error("Passed value has no valid rawmetatable")
				local orgmetamethod = meta[metamethod]

				setreadonly(meta, false)
				meta[metamethod] = func

				setreadonly(meta, true)
				return orgmetamethod
			end
		end
	end,

	cstackoverflow = if not hookfunction then nil else function(func)
		for i = 1, 200 do
			local h; h = hookfunction(func, newcclosure(function(...)
				return h(...)
			end))
			if i == 200 then
				return h
			end
		end
	end,

	clonefunction = clonefunc or clonefunction or clone_function or function(fnc)
		return
			if islclosure(fnc) then function(...)
				return fnc(...)
			end
			else
			newcclosure(fnc);
	end,

	-- this isnt too reliable but regardless a non-recursive lua function should never have itself as an upvalue
	isrecursive = if not getupvalues then nil else function(func)
		return (typeof(func) == "function" and islclosure(func) and table.find(getupvalues(func), func) ~= nil) or false
	end,

	getmaxstacklevel = function()
		for i = 0, 20000 do
			if not debug.info(i+2, "f") then
				return i
			end
		end
	end,

	ygetmaxstacklevel = function()
		for i = 0, 20000 do
			if not debug.info(i+2, "f") then
				return i
			end

			if i % 200 == 0 then task.wait() end
		end
	end,

	gs = function(classname: string) -- gs is very shortened but GetService also exists by itself ;)
		return game:GetService(classname)
	end,

	getcallingscript = function(level)
		level = level and level + 1 or 1
		local scr = rawget(getfenv(level), "script")

		if typeof(scr) ~= "Instance" then
			return scr
		end

		return nil, "Script was not an Instance"
	end,

	getcallingthread = function()
		return coroutine.running()
	end,

	getcallingfunction = function(maxdepth, leveldescent)
		maxdepth = maxdepth or 25
		leveldescent = leveldescent or 0

		for i = maxdepth, 1, -1 do
			if debug.info(i, "f") and i-leveldescent >= 0 then
				return debug.info(i-leveldescent, "f")
			end
		end

		return nil, "Function not found"
	end,

	isrealconnectionsrequired = function()
		local part = Instance.new("Part")
		local conn = part.Changed:Connect(assert)

		for i, v in next, getconnections(part.Changed) do
			v:Disable()
		end

		local bool = not conn.Connected			
		conn:Disconnect()
		conn = nil
		part:Destroy()
		part = nil

		return bool
	end,

	getrealconnections = function(signal)
		local tbl = {}

		for i, v in getgc(true) do
			if typeof(v) == "RBXScriptConnection" and v.Connected then
				table.insert(tbl, v)
			end
		end

		if signal and getconnections then
			local tbl2 = {}
			for i, v in next, getconnections(signal) do
				v:Disable()
			end
			for i, v in pairs(tbl) do
				if not v.Connected then
					table.insert(tbl2, v)
				end
			end
			for i, v in next, getconnections(signal) do
				v:Enable()
			end
			return tbl2
		end

		return tbl
	end,

	getcs = function()
		return game:GetService("CoreGui").RobloxGui:FindFirstChild("Folder") or Instance.new("Folder", game:GetService("CoreGui").RobloxGui)
	end,

	checkvar = function(method: string, str: string): boolean
		method = method:gsub("^%u", string.lower)
		str = str:gsub("^%u", string.lower)

		return method == str or (string.find(method, str) and string.sub(method, 1, string.len(str)+1) == str .. "\0")
	end,

	getrh = function()
		if gethui and gethui() ~= game:GetService("CoreGui") then -- [[ (._.) ]]
			return gethui()
		else
			return game:GetService("CoreGui").RobloxGui:FindFirstChild("Folder") or Instance.new("Folder", game:GetService("CoreGui").RobloxGui)
		end
	end,

	hookgcinfo = if not hookfunction then nil else function()
		return loadstring(game:HttpGet("https://raw.githubusercontent.com/FaithfulAC/universal-stuff/main/true-secure-dex-bypasses.lua"))({
			gcinfo = true
		})
	end,

	hookmem = if not (hookmetamethod and hookfunction) then nil else function()
		return loadstring(game:HttpGet("https://raw.githubusercontent.com/FaithfulAC/universal-stuff/main/true-secure-dex-bypasses.lua"))({
			GetTotalMemoryUsageMb = true
		})
	end,

	hookguimemtag = if not (hookmetamethod and hookfunction) then nil else function() -- only supports Enum.DeveloperMemoryTag.Gui
		return loadstring(game:HttpGet("https://raw.githubusercontent.com/FaithfulAC/universal-stuff/main/true-secure-dex-bypasses.lua"))({
			GetMemoryUsageMbForTag = true
		})
	end,

	hookpreloadasync = if not (hookmetamethod and hookfunction) then nil else function()
		return loadstring(game:HttpGet("https://raw.githubusercontent.com/FaithfulAC/universal-stuff/main/true-secure-dex-bypasses.lua"))({
			PreloadAsync = true
		})
	end,

	hooktextbox = if not (hookmetamethod and hookfunction) then nil else function(ins)
		ins = ins or game:GetService("CoreGui").RobloxGui
		return loadstring(game:HttpGet("https://raw.githubusercontent.com/FaithfulAC/universal-stuff/main/true-secure-dex-bypasses.lua"))({
			GetFocusedTextBox = true
		}, ins)
	end,

	getmem = function()
		return game:GetService("Stats"):GetTotalMemoryUsageMb()
	end,

	getmemtag = function(enum)
		return game:GetService("Stats"):GetMemoryUsageMbForTag(enum)
	end,

	setmemtaginflation = function(bool: boolean, enum: Enum) -- only supports script and gui lol (default is gui)
		local scrfunc = getgenv().memtagscriptfunc
		local guifunc = getgenv().memtagguifunc

		if bool == false then
			if scrfunc then scrfunc:Disconnect() getgenv().memtagscriptfunc = nil end
			if guifunc then guifunc:Disconnect() getgenv().memtagguifunc = nil end
			return
		end

		if enum == Enum.DeveloperMemoryTag.Script or tostring(enum):lower():find("scr") then
			if scrfunc then return end
			getgenv().memtagscriptfunc =  game:GetService("RunService").Heartbeat:Connect(function()
				task.spawn(function(...) -- doing random stuff to increase script activity
					for i = 1, 100 do
						local a = Instance.new("Script")
						a.Enabled = false
						a.Disabled = false
						a:Destroy()
					end
					for i, v in pairs(workspace:GetDescendants()) do pcall(v.SetAttribute) end
				end)
			end)
		else -- gui or default (gui)
			if guifunc then return end
			getgenv().memtagguifunc = game:GetService("RunService").Heartbeat:Connect(function()
				for i = 1, 10 do
					local frame = Instance.new("Frame")
					task.spawn(function()
						task.wait(1)
						frame:Destroy()
					end)
				end
			end)
		end
	end,

	isalive = isalive or function(): boolean -- thank u electron for the idea :))))))))))
		return game:GetService("Stats").DataSendKbps ~= 0 and game:GetService("Stats").DataReceiveKbps ~= 0
	end,

	setgcinflation = function(bool: boolean)
		local tbl = getgenv().gcinflationtable

		if bool == false then
			if tbl then table.clear(tbl) getgenv().gcinflationtable = nil end
			return
		end
		getgenv().gcinflationtable = {}

		task.spawn(function()
			while getgenv().gcinflationtable do
				for i = 1, math.random(100,200) do
					table.insert(getgenv().gcinflationtable or {}, table.create(1500, {}))
					task.wait()
				end
				if math.random() > 0.7 then
					table.clear(getgenv().gcinflationtable or {})
				end
				task.wait()
			end
		end)
	end,

	setvarintbl = function(gtbl, varname: string, newvar)
		local istbl = nil

		local target do
			if type(gtbl) == "string" then
				target = getrenv()[gtbl]
				istbl = false
			elseif type(gtbl) == "table" then
				target = getrenv()[table.find(getrenv(), gtbl)]
				istbl = true
			else
				return error("bad argument #1 to 'setvarintable' (table or string expected)")
			end
		end

		local unpacktbl = {unpack(target)}
		unpacktbl[varname] = nil

		local metatable = {
			__tostring = function(a)
				return tostring(target)
			end,
			__eq = function(a,b)
				return target == b
			end,
			__metatable = getmetatable(target)
		}

		if istbl then
			getrenv()[table.find(getrenv(), gtbl)] = setmetatable({
				[varname] = newvar, unpack(unpacktbl)
			}, metatable)
		else
			getrenv()[gtbl] = setmetatable({
				[varname] = newvar, unpack(unpacktbl)
			}, metatable)
		end
	end,

	hookvarintbl = function(gtbl, varname: string, newvar)
		if typeof(gtbl) ~= "table" then
			return error("bad argument #1 to 'hookvarintable' (table expected)")
		end

		local rawmt = getrawmetatable(gtbl)

		if not rawmt.__index then return "No metamethod for __index" end

		local h; h = hookfunction(rawmt.__index, function(...)
			local self, arg = ...

			if not checkcaller() and rawequal(self, gtbl) and typeof(arg) == "string" and arg == varname then
				return newvar
			end

			return h(...)
		end)
	end,

	disconn = function(conn, hookFunc)
		for i, v in next, getconnections(conn) do
			-- this can be detected if one connects the same function to 2 connections and triggers the other connection. Just saying
			if hookFunc then hookfunction(v.Function, function() return end) continue end
			v:Disable()
		end
	end,

	spoofconns = if not (hookmetamethod and hookfunction) then nil else function(signal, exclusions, inclusions, waithook: boolean)
		-- if isrealconnectionsrequired returns false then there is no need to load this function for the most part (and it wont even work proper)
		local conn = game.Changed:Connect(assert)
		local conncache;
		if signal then
			conncache = setmetatable({}, {__mode = "v"})
			if exclusions and not inclusions then
				for i, v in pairs(exclusions) do
					if table.find(conncache, v) then table.remove(conncache, table.find(conncache, v)) end
				end
			elseif inclusions then
				for i, v in pairs(inclusions) do
					table.insert(conncache, v)
				end
			else
				table.insert(conncache, unpack((isrealconnectionsrequired() and getrealconnections or getconnections)(signal)))
			end
		end

		local h; h = hookmetamethod(conn, "__index", newcclosure(function(...)
			local self, prop = ...
			if
				not checkcaller() and
				typeof(self) == "RBXScriptConnection" and
				((signal ~= nil and conncache ~= nil and #conncache > 0 and table.find(conncache, self)) or true) and
				typeof(prop) == "string" and
					string.gsub(string.split(prop, "\0")[1], "^%u", string.lower) == "connected"
			then
				return true
			end
			return h(...)
		end))
	end,

	clientran = function(scr: Instance)
		return scr.ClassName == "LocalScript" or (scr.ClassName == "Script" and (scr.RunContext == Enum.RunContext.Client or scr.RunContext == Enum.RunContext.Legacy))
	end,

	serverran = function(scr: Instance)
		return scr.ClassName == "Script" and scr.RunContext ~= Enum.RunContext.Client
	end,

	antihttp = function(grabArgs: boolean)
		if not grabArgs then
			getgenv().request = nil
			getgenv().httprequest = nil
			getgenv().http_request = nil
		else
			local newfunc = newcclosure(function(tbl)
				warn("httprequest was triggered! Here are the arguments:")

				if type(tbl) == "table" then
					for i, v in pairs(tbl) do
						print(i, v)
					end
				else
					print(tbl)
				end

				warn("End of arguments")
			end)

			getgenv().request = newfunc
			getgenv().httprequest = newfunc
			getgenv().http_request = newfunc
		end
	end,

	antiweaktable = if not hookfunction then nil else function()
		return loadstring(game:HttpGet("https://raw.githubusercontent.com/FaithfulAC/universal-stuff/main/true-secure-dex-bypasses.lua"))({
			Weaktable = true
		})
	end,

	antitostring = if not getgc then nil else function()
		for i, v in getgc(true) do
			if type(v) == "table" and type(getrawmetatable(v)) == "table" and not table.isfrozen(v) and not table.isfrozen(getrawmetatable(v)) then
				if rawget(getrawmetatable(v),"__tostring") then
					rawset(getrawmetatable(v), "__tostring", nil)
				end
			end
		end
	end,

	safetostring = function(...)
		local args = {...}
		local getrawmetatable = getrawmetatable or debug.getmetatable or getmetatable

		-- since varargs will automatically convert last args that are nil to nothing, we can just make them "nil" (not using table.pack)
		if #args < select("#", ...) then
			for i = #args+1, select("#",...) do
				args[i] = "nil"
			end
		end

		for i, v in pairs(args) do
			if (typeof(v) == "table" or typeof(v) == "userdata") and getrawmetatable(v) and rawget(getrawmetatable(v), "__tostring") then
				local mt = getrawmetatable(v)
				local func = rawget(mt, "__tostring")
				rawset(mt, "__tostring", nil)
				args[i] = tostring(v)
				rawset(mt, "__tostring", func)
			else
				args[i] = tostring(v)
			end
		end

		return unpack(args)
	end,

	safeprint = function(...)
		return print(safetostring(args))
	end,

	getscripts = if not getinstances then nil else getscripts or function()
		local tbl = {}

		for i, v in getinstances() do
			if typeof(v) == "Instance" and v:IsA("LocalScript") or v:IsA("ModuleScript") then
				table.insert(tbl, v)
			end
		end

		return tbl
	end,

	getserverscripts = if not getinstances then nil else function()
		local tbl = {}

		for i, v in getinstances() do
			if typeof(v) == "Instance" and v:IsA("Script") then
				table.insert(tbl, v)
			end
		end

		return tbl
	end,

	getrems = if not getinstances then nil else function()
		local tbl = {}

		for i, v in getinstances() do
			if typeof(v) == "Instance" and v:IsA("BaseRemoteEvent") then
				table.insert(tbl, v)
			end
		end

		return tbl
	end,

	grabargs = if not (hookmetamethod and hookfunction) then nil else function(rem: RemoteEvent) -- local a = {grabargs(rem)}
		rem = cloneref(rem)
		local args = nil
		local actualnumofvals = 0

		local h; h = hookfunction(rem.FireServer, function(...)
			local self = ...

			if typeof(self) == "Instance" and compareinstances(self, rem) then
				args = {select(2,...)}
				actualnumofvals = select("#", ...)-1
			end

			return h(...)
		end)

		local h2; h2 = hookmetamethod(game,"__namecall", function(...)
			local self = ...
			local method = getnamecallmethod():gsub("^%l", string.upper)

			if typeof(self) == "Instance" and compareinstances(self, rem) and method == "fireServer" then
				args = {select(2,...)}
				actualnumofvals = select("#", ...)-1
			end

			return h2(...)
		end)
		while args == nil and task.wait() do end

		hookfunction(rem.FireServer, h)
		hookmetamethod(game,"__namecall", h2)

		return unpack(args, 1, actualnumofvals)
	end,

	gettables = if not getgc then nil else function()
		local tbl = {} -- lol
		for i, v in getgc(true) do
			if type(v) == "table" then
				table.insert(tbl, v)
			end
		end
		return tbl
	end,

	getmetatables = if not getgc then nil else function()
		local tbl = {}
		for i, v in getgc(true) do
			if (typeof(v) == "table" or typeof(v) == "userdata") and getrawmetatable(v) then
				table.insert(tbl, getrawmetatable(v))
			end
		end
		return tbl
	end,

	getfunctions = if not getgc then nil else function()
		local tbl = {}
		for i, v in getgc() do
			if type(v) == "function" then
				table.insert(tbl, v)
			end
		end
		return tbl
	end,

	getlfunctions = if not (getgc and islclosure) then nil else function()
		local tbl = {}
		for i, v in getgc() do
			if type(v) == "function" and islclosure(v) then
				table.insert(tbl, v)
			end
		end
		return tbl
	end,

	getcfunctions = if not (getgc and iscclosure) then nil else function()
		local tbl = {}
		for i, v in getgc() do
			if type(v) == "function" and iscclosure(v) then
				table.insert(tbl, v)
			end
		end
		return tbl
	end,

	breakjoints = function()
		return game:GetService("Players").LocalPlayer and game:GetService("Players").LocalPlayer.Character and game:GetService("Players").LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid") and game:GetService("Players").LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid"):BreakJoints()
	end,

	isnil = function(a: Instance)
		return a.Parent == nil
	end,

	isSTDbait = function(tbl) -- wont work if they put the __tostring table within multiple tables ({{{__tostringbait}}})
		if typeof(tbl) ~= "table" then
			return false
		end

		for i in pairs(tbl) do
			if (typeof(i) == "table" or typeof(i) == "userdata") and getrawmetatable(i) ~= nil and rawget(getrawmetatable(i), "__tostring") then
				return rawget(getrawmetatable(i), "__tostring")
			end
		end

		return false
	end,

	antikick = if not (hookmetamethod and hookfunction) then nil else function(yield: boolean) -- default is false
		return loadstring(game:HttpGet("https://raw.githubusercontent.com/FaithfulAC/Megaprojects/refs/heads/main/total_anti_disconnect.lua"))(yield)
	end,

	disablenamecallhooks = if not hookmetamethod then nil else function(duration: number)
		if (not duration) or typeof(duration) ~= "number" then duration = 1 end
		local h;

		if hookfunction then
			h = hookfunction(getgenv().hookmetamethod, function(mt, method, func)
				if method == "__namecall" then return end
				return h(mt, method, func)
			end)
		else
			h = getgenv().hookmetamethod

			getgenv().hookmetamethod = newcclosure(function(mt, method, func)
				if method == "__namecall" then return end
				return h(mt, method, func)
			end)
		end
		task.spawn(function()
			task.wait(duration)

			if hookfunction then
				hookfunction(getgenv().hookmetamethod, h)
			else
				getgenv().hookmetamethod = h
			end
		end)
	end,

	disableindexhooks = if not hookmetamethod then nil else function(duration: number)
		if (not duration) or typeof(duration) ~= "number" then duration = 1 end
		local h;

		if hookfunction then
			h = hookfunction(getgenv().hookmetamethod, function(mt, method, func)
				if method == "__index" then return end
				return h(mt, method, func)
			end)
		else
			h = getgenv().hookmetamethod

			getgenv().hookmetamethod = newcclosure(function(mt, method, func)
				if method == "__index" then return end
				return h(mt, method, func)
			end)
		end
		task.spawn(function()
			task.wait(duration)

			if hookfunction then
				hookfunction(getgenv().hookmetamethod, h)
			else
				getgenv().hookmetamethod = h
			end
		end)
	end,

	disablenewindexhooks = if not hookmetamethod then nil else function(duration: number)
		if (not duration) or typeof(duration) ~= "number" then duration = 1 end
		local h;

		if hookfunction then
			h = hookfunction(getgenv().hookmetamethod, function(mt, method, func)
				if method == "__newindex" then return end
				return h(mt, method, func)
			end)
		else
			h = getgenv().hookmetamethod

			getgenv().hookmetamethod = newcclosure(function(mt, method, func)
				if method == "__newindex" then return end
				return h(mt, method, func)
			end)
		end
		task.spawn(function()
			task.wait(duration)

			if hookfunction then
				hookfunction(getgenv().hookmetamethod, h)
			else
				getgenv().hookmetamethod = h
			end
		end)
	end,

	-- waits until x seconds have passed to reinstate hook-based functions
	removehooks = function(duration: number)
		if not duration then duration = 1 end

		task.spawn(function()
			local hf, hmm = getgenv().hookfunction, getgenv().hookmetamethod

			getgenv().hookfunction = newcclosure(function()end)
			getgenv().hookmetamethod = newcclosure(function()end)

			task.wait(duration)

			getgenv().hookfunction = hf
			getgenv().hookmetamethod = hmm
		end)
	end,

	-- waits until both functions are called x times to reinstate hook-based functions
	removehooks2 = function(maxcallcount: number)
		task.spawn(function()
			local hf, hmm = getgenv().hookfunction, getgenv().hookmetamethod
			local callcount = 0;

			getgenv().hookfunction = newcclosure(function(...)
				callcount = callcount + 1;

				if callcount >= maxcallcount then
					getgenv().hookfunction = hf
					getgenv().hookmetamethod = hmm

					return hf(...)
				end
			end)

			getgenv().hookmetamethod = newcclosure(function(...)
				callcount = callcount + 1;

				if callcount >= maxcallcount then
					getgenv().hookfunction = hf
					getgenv().hookmetamethod = hmm

					return hmm(...)
				end
			end)
		end)
	end,

	anticrash = function()
		return game:GetService("ScriptContext"):SetTimeout(1)
	end,

	ls = function(url: string)
		return loadstring(game:HttpGet(url))()
	end,

	hookinscount = if not (hookmetamethod and hookfunction) then nil else function()
		return loadstring(game:HttpGet("https://raw.githubusercontent.com/FaithfulAC/universal-stuff/main/true-secure-dex-bypasses.lua"))({
			InstanceCount = true
		})
	end,

	waithookfunc = if not hookfunction then nil else function(fnc)
		local h; h = hookfunction(fnc, function(...)
			return if not checkcaller() and (h ~= coroutine.isyieldable and coroutine.isyieldable()) then wait(9e9) else h(...)
		end)
	end,

	antibodycheck = function()
		local char = getcharacter() or game:GetService("Players").LocalPlayer.Character
		local root, torso do
			if char then root = char:FindFirstChild("HumanoidRootPart") torso = char:FindFirstChild("Torso") end
		end

		for i, v in next, getconnections(char.DescendantAdded) do
			v:Disable()
		end

		local function dothing(obj)
			for i, v in next, getconnections(obj.ChildAdded) do
				v:Disable()
			end
			for i, v in next, getconnections(obj.DescendantAdded) do
				v:Disable()
			end
			for i, v in next, getconnections(obj.Changed) do
				v:Disable()
			end
		end

		if root then dothing(root) end
		if torso then dothing(torso) end
	end,

	antihumcheck = function() -- can interfere with looping ws/jp/jh related functions
		local hum = gethumanoid() or game:GetService("Players").LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")

		local function dothing(signal)
			for i, v in next, getconnections(signal) do
				v:Disable()
			end
		end

		dothing(hum.Changed)
		dothing(hum:GetPropertyChangedSignal("WalkSpeed"))
		dothing(hum:GetPropertyChangedSignal("JumpPower"))
		dothing(hum:GetPropertyChangedSignal("HipHeight"))
		dothing(hum:GetPropertyChangedSignal("JumpHeight"))
		dothing(hum:GetPropertyChangedSignal("MaxSlopeAngle"))
	end,

	setnoclip = function(bool: boolean)
		if not bool then
			if noclipconn then
				noclipconn:Disconnect()
			end

			getgenv().noclipconn = nil
			return
		end

		getgenv().noclipconn = noclipconn or game:GetService("RunService").Stepped:Connect(function()
			pcall(function()
				for i, v in pairs(game:GetService("Players").LocalPlayer.Character:GetChildren()) do
					if v:IsA("BasePart") then v.CanCollide = false end
				end
			end)
		end)
	end,

	setws = function(int: number, loopHum: boolean)
		local hum: Humanoid = gethumanoid()
		if hum and loopHum then
			if getgenv().wsloop then
				getgenv().wsloop:Disconnect()
				getgenv().wsloop = nil
			end

			getgenv().wsloop = hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
				hum.WalkSpeed = int
			end)

			local upvalconn;

			local upvalfunc; upvalfunc = function()
				if getgenv().wsloop then
					getgenv().wsloop:Disconnect()
					getgenv().wsloop = nil
				end

				repeat task.wait() until (not hum) or hum.Parent == nil;
				hum = gethumanoid()

				if upvalconn then
					upvalconn:Disconnect()
					upvalconn = nil;
				end

				upvalconn = hum.Died:Connect(upvalfunc)
			end

			upvalconn = hum.Died:Connect(upvalfunc)
		end

		hum.WalkSpeed = int
	end,

	setjp = function(int: number, loopHum: boolean)
		local hum = gethumanoid()
		if hum and loopHum then
			if getgenv().jploop then
				getgenv().jploop:Disconnect()
				getgenv().jploop = nil
			end

			getgenv().jploop = hum:GetPropertyChangedSignal("JumpPower"):Connect(function()
				hum.JumpPower = int
			end)

			local upvalconn;

			local upvalfunc; upvalfunc = function()
				if getgenv().jploop then
					getgenv().jploop:Disconnect()
					getgenv().jploop = nil
				end

				repeat task.wait() until (not hum) or hum.Parent == nil;
				hum = gethumanoid()

				if upvalconn then
					upvalconn:Disconnect()
					upvalconn = nil;
				end

				upvalconn = hum.Died:Connect(upvalfunc)
			end

			upvalconn = hum.Died:Connect(upvalfunc)
		end

		hum.JumpPower = int
	end,

	setjpenabled = function(bool: boolean, loopHum: boolean)
		local hum = gethumanoid()

		if hum and loopHum then
			if getgenv().jpenabledloop then
				getgenv().jpenabledloop:Disconnect()
				getgenv().jpenabledloop = nil
			end

			getgenv().jpenabledloop = hum:GetPropertyChangedSignal("UseJumpPower"):Connect(function()
				hum.UseJumpPower = bool
			end)

			local upvalconn;

			local upvalfunc; upvalfunc = function()
				if getgenv().jpenabledloop then
					getgenv().jpenabledloop:Disconnect()
					getgenv().jpenabledloop = nil
				end

				repeat task.wait() until (not hum) or hum.Parent == nil;
				hum = gethumanoid()

				if upvalconn then
					upvalconn:Disconnect()
					upvalconn = nil;
				end

				upvalconn = hum.Died:Connect(upvalfunc)
			end

			upvalconn = hum.Died:Connect(upvalfunc)
		end

		hum.UseJumpPower = bool
	end,

	sethh = function(int: number, loopHum: boolean)
		local hum = gethumanoid()

		if hum and loopHum then
			if getgenv().hhloop then
				getgenv().hhloop:Disconnect()
				getgenv().hhloop = nil
			end

			getgenv().hhloop = hum:GetPropertyChangedSignal("HipHeight"):Connect(function()
				hum.HipHeight = int
			end)

			local upvalconn;

			local upvalfunc; upvalfunc = function()
				if getgenv().hhloop then
					getgenv().hhloop:Disconnect()
					getgenv().hhloop = nil
				end

				repeat task.wait() until (not hum) or hum.Parent == nil;
				hum = gethumanoid()

				if upvalconn then
					upvalconn:Disconnect()
					upvalconn = nil;
				end

				upvalconn = hum.Died:Connect(upvalfunc)
			end

			upvalconn = hum.Died:Connect(upvalfunc)
		end

		hum.HipHeight = int
	end,

	setmsa = function(int: number, loopHum: boolean)
		local hum = gethumanoid()

		if hum and loopHum then
			if getgenv().msaloop then
				getgenv().msaloop:Disconnect()
				getgenv().msaloop = nil
			end

			getgenv().msaloop = hum:GetPropertyChangedSignal("MaxSlopeAngle"):Connect(function()
				hum.MaxSlopeAngle = int
			end)

			local upvalconn;

			local upvalfunc; upvalfunc = function()
				if getgenv().msaloop then
					getgenv().msaloop:Disconnect()
					getgenv().msaloop = nil
				end

				repeat task.wait() until (not hum) or hum.Parent == nil;
				hum = gethumanoid()

				if upvalconn then
					upvalconn:Disconnect()
					upvalconn = nil;
				end

				upvalconn = hum.Died:Connect(upvalfunc)
			end

			upvalconn = hum.Died:Connect(upvalfunc)
		end

		hum.MaxSlopeAngle = int
	end,

	setgrav = function(int: number, loopGrav: boolean)
		if getgenv().gravloop then
			getgenv().gravloop:Disconnect()
			getgenv().gravloop = nil
		end

		if loopGrav then
			getgenv().gravloop = workspace:GetPropertyChangedSignal("Gravity"):Connect(function()
				workspace.Gravity = int
			end)
		end

		workspace.Gravity = int
	end,

	setinfjump = function(bool: boolean)
		if bool then
			getgenv().infjumpconn = game:GetService("UserInputService").JumpRequest:Connect(function()
				pcall(function()
					gethumanoid():ChangeState(Enum.HumanoidStateType.Jumping)
				end)
			end)
		else
			if getgenv().infjumpconn then
				getgenv().infjumpconn:Disconnect()
				getgenv().infjumpconn = nil
			end
		end
	end,

	setinfjump2 = function(bool: boolean)
		if bool then
			getgenv().infjump2conn = game:GetService("UserInputService").JumpRequest:Connect(function()
				pcall(function()
					local hum = gethumanoid()

					if hum.FloorMaterial == Enum.Material.Air then
						local oldVel = hum.RootPart.Velocity
						hum.RootPart.Velocity = Vector3.new(oldVel.X, hum.JumpPower, oldVel.Z)
					end
				end)
			end)
		else
			if getgenv().infjump2conn then
				getgenv().infjump2conn:Disconnect()
				getgenv().infjump2conn = nil
			end
		end
	end,

	setinfjump3 = function(bool: boolean)
		if bool then
			getgenv().infjump3conn = game:GetService("UserInputService").JumpRequest:Connect(function()
				pcall(function()
					local char, hum = getcharacter(), gethumanoid()
					local root, jh = hum.RootPart, hum.JumpHeight

					if hum.FloorMaterial == Enum.Material.Air then
						char:TranslateBy(Vector3.new(0, jh, 0))

						local oldVel = root.Velocity
						root.Velocity = Vector3.new(oldVel.X, jh, oldVel.Z)
					end
				end)
			end)
		else
			if getgenv().infjump3conn then
				getgenv().infjump3conn:Disconnect()
				getgenv().infjump3conn = nil
			end
		end
	end,

	setcframews = function(int: number)
		if getgenv().cframews then
			getgenv().cframews:Disconnect()
			getgenv().cframews = nil
		end

		getgenv().cframews = game:GetService("RunService").Stepped:Connect(function()
			pcall(function()
				local vec3delta = gethumanoid().MoveDirection
				getcharacter():TranslateBy(vec3delta * Vector3.new(int, 0, int))
			end)
		end)
	end,

	reset = function()
		local hum = gethumanoid()
		local oldRig = hum.RigType

		if hum.RigType == Enum.HumanoidRigType.R6 then
			hum.RigType = Enum.HumanoidRigType.R15
		else
			hum.RigType = Enum.HumanoidRigType.R6
		end

		hum.RigType = oldRig
	end,

	loadiy = function()
		return loadstring(game:HttpGet(('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'),true))()
	end,

	loadcmdx = function()
		return loadstring(game:HttpGet("https://raw.githubusercontent.com/CMD-X/CMD-X/master/Source", true))()
	end,

	loadsdex = function() -- warning: superly too many detection vectors possible for this, operate at your own risk
		return loadstring(game:HttpGet("https://raw.githubusercontent.com/Babyhamsta/RBLX_Scripts/main/Universal/BypassedDarkDexV3.lua"))()
	end,

	loaddex = function()
		return loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))()
		--loadstring(game:HttpGet("https://raw.githubusercontent.com/FaithfulAC/universal-stuff/main/true-secure-dex.lua"))(false) -- broken rn
	end,

	loadtsdex = function() -- preset for bypassing in-game anticheats with a blue/purple-themed dex
		return loadstring(game:HttpGet("https://raw.githubusercontent.com/FaithfulAC/universal-stuff/main/true-secure-dex.lua"))()
	end,

	loadss = function()
		return loadstring(game:HttpGet("https://raw.githubusercontent.com/78n/SimpleSpy/main/SimpleSpySource.lua"))()
	end,

	loadv4 = function()
		return loadstring(game:HttpGet("https://raw.githubusercontent.com/7GrandDadPGN/VapeV4ForRoblox/main/NewMainScript.lua", true))()
	end,

	loadtsdbypasses = if not (hookmetamethod and hookfunction) then nil else function(options, ins)
		options, ins = options, ins or game:GetService("CoreGui").RobloxGui
		return loadstring(game:HttpGet("https://raw.githubusercontent.com/FaithfulAC/universal-stuff/refs/heads/main/true-secure-dex-bypasses.lua"))(options, ins)
	end,

	rj = function()
		game:GetService("TeleportService"):Teleport(game.PlaceId)
	end,

	loadinternal = function()
		return loadstring(game:HttpGet("https://raw.githubusercontent.com/FaithfulAC/universal-stuff/refs/heads/main/internal.lua"))()
	end
}
getgenv().europa = europa

europa["FindFirstGameDescendantWithDebugId"] = europa.FindFirstDataModelDescendantWithDebugId
europa["FindFirstGameDescendantOfClass"] = europa.FindFirstDataModelDescendantOfClass
europa["fti"] = europa.firetouchinterest
europa["clonefunc"] = europa.clonefunction
europa["yieldgetmaxstacklevel"] = europa.ygetmaxstacklevel
europa["replacehmm"] = europa.replacehookmetamethod
europa["getservice"], europa["GetService"] =
	europa.gs, europa.gs;

europa["isrealconnsrequired"] = europa.isrealconnectionsrequired
europa["getrealconns"] = europa.getrealconnections
europa["getcoresecure"] = europa.getcs
europa["checkvariable"] = europa.checkvar
europa["getrealhidden"], europa["getrhui"] =
	europa.getrh, europa.getrh;

europa["getmemory"] = europa.getmem
europa["getmemorytag"] = europa.getmemtag
europa["hookmemory"] = europa.hookmem
europa["hookPreloadAsync"] = europa.hookpreloadasync
europa["getremotes"] = europa.getrems
europa["getluafunctions"] = europa.getlfunctions
europa["isnilinstance"] = europa.isnil
europa["setmemoryinflation"] = europa.setmeminflation
europa["setmemorytaginflation"] = europa.setmemtaginflation
europa["setvarintable"], europa["setvariableintable"] =
	europa.setvarintbl, europa.setvarintbl;

europa["hookvarintable"], europa["hookvariableintable"] =
	europa.hookvarintbl, europa.hookvarintbl;

europa["disconnect"] = europa.disconn
europa["spoofconnections"] = europa.spoofconns
europa["isclient"] = europa.clientran
europa["isserver"] = europa.serverran
europa["quickload"], europa["quickLoad"] =
	europa.ls, europa.ls

europa["hookinstancecount"] = europa.hookinscount
europa["waithookfunction"], europa["yieldfunc"], europa["yieldfunction"] =
	europa.waithookfunc, europa.waithookfunc, europa.waithookfunc;

europa["antihumanoidcheck"] = europa.antihumcheck
europa["setwalkspeed"] = europa.setws
europa["setjumppower"] = europa.setjp
europa["sethipheight"] = europa.sethh
europa["setmaxslopeangle"] = europa.setmsa
europa["setgravity"] = europa.setgrav
europa["setinfinitejump"] = europa.setinfjump
europa["setinfinitejump2"], europa["setvelinfjump"] =
	europa.setinfjump2, europa.setinfjump2

europa["setinfinitejump3"], europa["setcframeinfjump"] =
	europa.setinfjump3, europa.setinfjump3

europa["setcframewalkspeed"] = europa.setcframews
europa["setjumppowerenabled"] = europa.setjpenabled
europa["loadinfiniteyield"] = europa.loadiy
europa["loadsecuredex"] = europa.loadsdex
europa["loadtruesecuredex"] = europa.loadtsdex
europa["loadsimplespy"] = europa.loadss
europa["loadvapev4"] = europa.loadv4
europa["loadbypasses"], europa["loadtsdexbypasses"], europa["loadtruesecuredexbypasses"] =
	europa.loadtsdbypasses, europa.loadtsdbypasses, europa.loadtsdbypasses
europa["rejoin"] = europa.rj

for i, v in europa do
	getgenv()[i] = v
end
