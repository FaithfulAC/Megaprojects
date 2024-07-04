-- for std::string stuff

local clonefunction = clonefunction or function(...) return ... end
local cloneref = cloneref or function(...) return ... end

local GetFullName = clonefunction(game.GetFullName)
local GetDebugId = clonefunction(game.GetDebugId)
local FindFirstChild = clonefunction(game.FindFirstChild)

repeat task.wait() until game:IsLoaded() and game:GetService("Players").LocalPlayer

getgenv().europa = {
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
		return pcall(function() GetFullName(game:GetService("CoreGui")) end)
	end,

	FindFirstDataModelDescendantOfClass = function(class: string)
		for i, v in pairs(game:GetDescendants()) do
			if v.ClassName == class then
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

	loadsafehookmetamethod = function(KeepOriginalFunction: boolean, DontLoadCStackOverflowBypass: boolean)
		getgenv().KeepHMM = KeepOriginalFunction
		getgenv().LoadCSOBypass = not DontLoadCStackOverflowBypass
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

	replacehookmetamethod = function()
		getgenv().hookmetamethod = function(...)
			local object, metamethod, func = ...
			if type(func) == "function" and islclosure(func) then
				func = newcclosure(func) -- either get C stack overflow'd or slnaf check'd, i'll go with C stack overflow'd
			end

			local meta = (pcall(getrawmetatable, object) and getrawmetatable(object)) or error("Passed value has no valid rawmetatable")
			local orgmetamethod = meta[metamethod]

			setreadonly(meta, false)
			meta[metamethod] = func

			setreadonly(meta, true)
			return orgmetamethod
		end
	end,

	cstackoverflow = if not hookfunction then nil else function(func)
		for i = 1, 200 do
			local h; h = hookfunction(func, function(...)
				return h(...)
			end)
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
		return (typeof(func) == "function" and table.find(getupvalues(func), func) ~= nil) or false
	end,

	getmaxstacklevel = function()
		for i = 0, 20000 do
			if not pcall(getfenv, i+3) then
				return i
			end
		end
	end,

	ygetmaxstacklevel = function()
		for i = 0, 20000 do
			if not pcall(getfenv, i+3) then
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

	getcallingfunction = function(leveldescent)
		leveldescent = leveldescent or 0

		for i = 25, 1, -1 do
			if debug.info(i, "f") and i-leveldescent >= 0 then
				return debug.info(i-leveldescent, "f")
			end
		end

		return nil, "Function not found"
	end,

	getrealconnections = function()
		local tbl = {}

		for i, v in getgc(true) do
			if typeof(v) == "RBXScriptConnection" then
				table.insert(tbl, v)
			end
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

	getmem = function()
		return game:GetService("Stats"):GetTotalMemoryUsageMb()
	end,

	getmemtag = function(enum: EnumItem)
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
		if enum == Enum.DeveloperMemoryTag.Script or tostring(enum):find("s") then
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

		if istbl then
			getrenv()[table.find(getrenv(), gtbl)] = {
				[varname] = newvar, unpack(unpacktbl)
			}
		else
			getrenv()[gtbl] = {
				[varname] = newvar, unpack(unpacktbl)
			}
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

	disconn = function(conn)
		for i, v in next, getconnections(conn) do
			v:Disable()
		end
	end,

	spoofconns = if not (hookmetamethod and hookfunction) then nil else function(waithook: boolean)
		-- unfortunately unable to determine the connection to disconnect so this is for all connections
		-- do spoofconns(true/false) then disconn(examplesignal)
		local conn = game.Changed:Connect(assert)

		local h; h = hookmetamethod(conn, "__index", newcclosure(function(...)
			local self, prop = ...
			if
				not checkcaller() and
				typeof(self) == "RBXScriptConnection" and
				typeof(prop) == "string" and
				string.gsub(string.split(prop, "\0")[1], "^%u", string.lower) == "connected"
			then
				return true
			end
			return h(...)
		end))
	end,

	clientran = function(scr: Instance)
		return scr.ClassName == "LocalScript" or (scr.ClassName == "Script" and scr.RunContext == Enum.RunContext.Client)
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

	antitostring = if not getgc then nil else function() -- fixing krnl decompiler detection i hope
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

		if #args < select("#", ...) then
			for i = #args+1, select("#",...) do
				args[i] = "nil"
			end
		end

		for i, v in args do
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
			if typeof(v) == "Instance" and  v:IsA("Script") then
				table.insert(tbl, v)
			end
		end
		return tbl
	end,

	getrems = if not getinstances then nil else function()
		local tbl = {}
		for i, v in getinstances() do
			if typeof(v) == "Instance" and v:IsA("RemoteEvent") then
				table.insert(tbl, v)
			end
		end
		return tbl
	end,

	grabargs = if not (hookmetamethod and hookfunction) then nil else function(rem: RemoteEvent) -- local a = {grabargs(rem)}
		rem = cloneref(rem)
		local args = nil
		local numofnilvals = 0

		local h; h = hookfunction(rem.FireServer, function(...)
			local self = ...

			if typeof(self) == "Instance" and compareinstances(self, rem) then
				args = {select(2,...)}
				numofnilvals = (select("#", ...) - 1) - #args
			end

			return h(...)
		end)

		local h2; h2 = hookmetamethod(game,"__namecall", function(...)
			local self = ...
			local method = getnamecallmethod():gsub("^%u", string.lower)

			if typeof(self) == "Instance" and compareinstances(self, rem) and method == "fireServer" then
				args = {select(2,...)}
				numofnilvals = (select("#", ...) - 1) - #args
			end

			return h2(...)
		end)
		while args == nil and task.wait() do end

		hookfunction(rem.FireServer, h)
		hookmetamethod(game,"__namecall", h2)

		return unpack(args, 1, numofnilvals)
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

	isSTDbait = function(tbl)
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

	antikick = if not (hookmetamethod and hookfunction) then nil else function()
		-- TODO: have load totalantidisconnect.lua
		local plr = game:GetService("Players").LocalPlayer

		local function CanCastToSTDString(value)
			return select(2, pcall(FindFirstChild, game, value)) ~= "Unable to cast value to std::string"
		end

		local h1;h1=hookmetamethod(game,"__namecall", function(...)
			local self, arg = ...

			if not checkcaller() and self == plr and (getnamecallmethod() == "Kick" or getnamecallmethod() == "kick") then
				if CanCastToSTDString(arg) then
					return wait(9e9)
				end
			end


			return h1(...)
		end)

		local h2;h2=hookfunction(plr.Kick, function(...)
			local self, arg = ...

			if not checkcaller() and self == plr then
				if CanCastToSTDString(arg) then
					return wait(9e9)
				end
			end

			return h2(...)
		end)
	end,

	removehooks = function(duration: number)
		task.spawn(function()
			local hf, hmm = getgenv().hookfunction, getgenv().hookmetamethod
			getgenv().hookfunction = function()end
			getgenv().hookmetamethod = function()end
			task.wait(duration or 2)
			getgenv().hookfunction = hf
			getgenv().hookmetamethod = hmm
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
		local char = game:GetService("Players").LocalPlayer.Character
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

	antihumcheck = function() -- can interfere with looping walkspeed
		local hum = game:GetService("Players").LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
		for i, v in next, getconnections(hum.Changed) do
			v:Disable()
		end
		for i, v in next, getconnections(hum:GetPropertyChangedSignal("WalkSpeed")) do
			v:Disable()
		end
		for i, v in next, getconnections(hum:GetPropertyChangedSignal("JumpPower")) do
			v:Disable()
		end
		for i, v in next, getconnections(hum:GetPropertyChangedSignal("HipHeight")) do
			v:Disable()
		end
		for i, v in next, getconnections(hum:GetPropertyChangedSignal("JumpHeight")) do
			v:Disable()
		end
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
		local hum = game:GetService("Players").LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
		if hum and loopHum then
			if getgenv().wsloop then
				getgenv().wsloop:Disconnect()
			end
			getgenv().wsloop = hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
				hum.WalkSpeed = int
			end)
		end
		hum.WalkSpeed = int
	end,

	setjp = function(int: number, loopHum: boolean)
		local hum = game:GetService("Players").LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
		if hum and loopHum then
			if getgenv().jploop then
				getgenv().jploop:Disconnect()
			end
			getgenv().jploop = hum:GetPropertyChangedSignal("JumpPower"):Connect(function()
				hum.JumpPower = int
			end)
		end
		hum.JumpPower = int
	end,

	setjpenabled = function(bool: boolean)
		local hum = game:GetService("Players").LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
		if hum then hum.UseJumpPower = bool end
	end,

	sethh = function(int: number)
		local hum = game:GetService("Players").LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
		if hum then hum.HipHeight = int end
	end,

	setgrav = function(int: number)
		workspace.Gravity = int
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

	loaddex = function() -- prevents hooks from being used in secure dex so it's basically dex v3 with cloneref and little to no detections occur
		loadstring(game:HttpGet("https://raw.githubusercontent.com/FaithfulAC/universal-stuff/main/true-secure-dex.lua"))(false)
	end,

	loadtsdex = function() -- preset for bypassing in-game anticheats with an outdated dex
		return loadstring(game:HttpGet("https://raw.githubusercontent.com/FaithfulAC/universal-stuff/main/true-secure-dex.lua"))()
	end,

	loadss = function()
		return loadstring(game:HttpGet("https://raw.githubusercontent.com/78n/SimpleSpy/main/SimpleSpySource.lua"))()
	end,

	loadv4 = function()
		return loadstring(game:HttpGet("https://raw.githubusercontent.com/7GrandDadPGN/VapeV4ForRoblox/main/NewMainScript.lua", true))()
	end,

	rj = function()
		game:GetService("TeleportService"):Teleport(game.PlaceId)
	end
}

europa["fti"] = europa.firetouchinterest
europa["clonefunc"] = europa.clonefunction
europa["yieldgetmaxstacklevel"] = europa.ygetmaxstacklevel
europa["replacehmm"] = europa.replacehookmetamethod
europa["getservice"], europa["GetService"] = europa.gs, europa.gs
europa["getcoresecure"] = europa.getcs
europa["checkvariable"] = europa.checkvar
europa["getrealhidden"], europa["getrhui"] = europa.getrh, europa.getrh
europa["getmemory"] = europa.getmem
europa["getmemorytag"] = europa.getmemtag
europa["hookmemory"] = europa.hookmem
europa["getremotes"] = europa.getrems
europa["getluafunctions"] = europa.getlfunctions
europa["isnilinstance"] = europa.isnil
europa["setmemoryinflation"] = europa.setmeminflation
europa["setmemorytaginflation"] = europa.setmemtaginflation
europa["setvarintable"], europa["setvariableintable"] = europa.setvarintbl, europa.setvarintbl
europa["hookvarintable"], europa["hookvariableintable"] = europa.hookvarintbl, europa.hookvarintbl
europa["disconnect"] = europa.disconn
europa["spoofconnections"] = europa.spoofconns
europa["isclient"] = europa.clientran
europa["isserver"] = europa.serverran
europa["quickload"], europa["quickLoad"] = europa.ls, europa.ls
europa["hookinstancecount"] = europa.hookinscount
europa["waithookfunction"] = europa.waithookfunc
europa["antihumanoidcheck"] = europa.antihumcheck
europa["setwalkspeed"] = europa.setws
europa["setjumppower"] = europa.setjp
europa["sethipheight"] = europa.sethh
europa["setmaxslopeangle"] = europa.setmsa
europa["setgravity"] = europa.setgrav
europa["setjumppowerenabled"] = europa.setjpenabled
europa["loadinfiniteyield"] = europa.loadiy
europa["loadsecuredex"] = europa.loadsdex
europa["loadtruesecuredex"] = europa.loadtsdex
europa["loadsimplespy"] = europa.loadss
europa["loadvapev4"] = europa.loadv4
europa["rejoin"] = europa.rj

for i, v in europa do
	getgenv()[i] = v
end
