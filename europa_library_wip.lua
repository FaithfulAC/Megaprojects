-- for rawinsequal (and std::string stuff)
local GetFullName = (clonefunction and clonefunction(game.GetFullName)) or game.GetFullName
local GetDebugId = (clonefunction and clonefunction(game.GetDebugId)) or game.GetDebugId
local FindFirstChild = (clonefunction and clonefunction(game.FindFirstChild)) or game.FindFirstChild

getgenv().europa = {
	Players = (cloneref and cloneref(game:GetService("Players"))) or game:GetService("Players"),
	LocalPlayer = game:GetService("Players").LocalPlayer or game:GetService("Players"):GetPropertyChangedSignal("LocalPlayer"):Wait(),
	hookfunc = hookfunction,

	getcharacter = function()
		local LocalPlayer = LocalPlayer or game:GetService("Players").LocalPlayer or game:GetService("Players"):GetPropertyChangedSignal("LocalPlayer"):Wait()
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

	-- this function is probably useless
	rawinsequal = compareinstances or function(ins1, ins2)
		if typeof(ins1) ~= typeof(ins2) and typeof(ins1) ~= "Instance" then return false end
		if ins1 == ins2 then return true end

		return GetFullName(ins1) == GetFullName(ins2) and GetDebugId(ins1, 10) == GetDebugId(ins2, 10)
	end,
	
	-- this isnt too reliable but regardless a non-recursive lua function should never have itself as an upvalue
	isrecursive = function(luafunc)
		if typeof(luafunc) ~= "function" or not islclosure(luafunc) then
			return error(("invalid argument #1 (lua function expected, got %s)"):format(typeof(luafunc)))
		end
		local upvals = debug.getupvalues or getupvalues

		for i, v in upvals(luafunc) do
			if v == luafunc then
				return true
			end
		end

		return false
	end

	gs = function(classname: string) -- gs is very shortened but GetService also exists by itself ;)
		return game:GetService(classname)
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

	-- dont use this one or the second just open devconsole and put it off to the side lol
	--[[hookggoap = if not (hookmetamethod and hookfunction) then nil else function()
		local pgui = game:GetService("Players").LocalPlayer:FindFirstChildWhichIsA("PlayerGui")
		local stuff = Instance.new("ScreenGui",pgui)
		stuff.Name = "TouchGui"
		local stuff2 = Instance.new("Frame",stuff)
		stuff2.Name = "TouchControlFrame"
		stuff2.Size = UDim2.fromScale(1,1)
		stuff2.Visible = false

		local gh1;gh1=hookmetamethod(game,"__namecall", function(...)
			local self = ...
			local method = getnamecallmethod():gsub("^%u", string.lower)

			if not checkcaller() and self == pgui and method == "getGuiObjectsAtPosition" then
				return {stuff2}
			end

			self=nil
			return gh1(...)
		end)
		local gh2;gh2=hookfunction(pgui.GetGuiObjectsAtPosition, function(...)
			local arg = ...

			if not checkcaller() and arg == pgui then
				return {stuff2}
			end

			arg=nil
			return gh1(...)
		end)
	end,

	hookggoap2 = if not (hookmetamethod and hookfunction) then nil else function()
		local guis = game:GetService("GuiService")

		for i, v in next, getconnections(guis.MenuClosed) do -- spoofconns maybe? ;)
			v:Disable()
		end

		local h;h=hookmetamethod(game,"__index", function(...)
			local self, arg = ...
			local _arg = (type(arg) == "string" and arg:gsub("^%u", string.lower)) or setmetatable({},{__namecall=function()return false end})

			if not checkcaller() and self == guis and _arg == "menuIsOpen" or _arg:sub(1, 11) == "menuIsOpen\0" then
				return true
			end

			self,arg=nil,nil
			return h(...)
		end)
	end,]]

	hookgcinfo = if not hookfunction then nil else function()
		local mini = 800
		local max = 1200

		local num = if gcinfo() < max and gcinfo() > mini then math.random(mini - 18, mini + 24) else gcinfo()

		if gcinfo() > max then max = gcinfo(); mini = max - math.floor(math.random(3, 6)*100) end
		if gcinfo() < mini then mini = gcinfo(); max = mini + math.floor(math.random(3, 6)*100) end

		task.spawn(function()
			while game:GetService("RunService").RenderStepped:Wait() do
				local int = math.random(4, 8)
				if num < max - math.random(10,30) then num = math.floor(num+int) game.ItemChanged:Wait() num += math.random(1,2) else
					num = math.floor(math.random(mini - 18, mini + 24))

					game.ItemChanged:Wait()
					num += 1
				end
			end
		end)
		local h;h=hookfunction(getrenv().gcinfo, function(...)
			if not checkcaller() then return num end
			return h(...)
		end)
		local h2;h2=hookfunction(getrenv().collectgarbage, function(...)
			local cnt = ... -- anti void detection
			if not checkcaller() and type(cnt) == "string" and (cnt == "count" or cnt:sub(1,6) == "count\0") then
				return num
			end

			cnt=nil
			return h2(...)
		end)
	end,

	hookgcinfo2 = if not hookfunction then nil else function() -- more realistic and less detectable by itemchanged		
		local max = gcinfo()+math.random(
		math.floor(gcinfo()/6),
		math.floor(gcinfo()/4)
		)
		local mini = gcinfo()-math.random(
		math.floor(gcinfo()/6),
		math.floor(gcinfo()/4)
		)

		-- this is so the value can be additionally made even more realistic so any detection bypasses can be easily adapted upon	
		getgenv().SpoofedGcReturn = gcinfo()

		local function decrease()
			for i = 1, 4 do
				getgenv().SpoofedGcReturn = max - math.floor(((max - mini*1.25)*(i/4))+math.random(-20,20))
				task.wait(math.random(25,45)/1000)
			end
		end

		local range1 = game:GetService("Stats").InstanceCount
		local range2 = range1 + math.random(1000, 3000)

		local clock = os.clock

		task.spawn(function()
			while '' do
				if getgenv().SpoofedGcReturn > max + math.random(-50,50) then decrease() end
				getgenv().SpoofedGcReturn += math.floor(math.random(range1,range2)/10000)

				local cont, passby = false, clock()

				local temp = game.ItemChanged:Once(function()
					getgenv().SpoofedGcReturn += math.random(2)

					game.ItemChanged:Once(function()
						getgenv().SpoofedGcReturn += 1
						cont = true
					end)
				end)

				repeat task.wait() until cont or clock() - passby > 0.05

				if clock() - passby > 0.05 then
					getgenv().SpoofedGcReturn += math.random(2)
				end
				temp:Disconnect()
			end
		end)

		local h1;h1=hookfunction(getrenv().gcinfo, function(...)
			return if not checkcaller() then getgenv().SpoofedGcReturn else h1(...)
		end)

		local h2;h2=hookfunction(getrenv().collectgarbage, function(...)
			local cnt = ...

			if not checkcaller() and type(cnt) == "string" and string.split(cnt, "\0")[1] == "count" then
				return getgenv().SpoofedGcReturn
			end

			cnt=nil
			return h2(...)
		end)
	end,

	hookmem = if not (hookmetamethod and hookfunction) then nil else function()
		local stats = game:GetService("Stats")
		local ret = stats:GetTotalMemoryUsageMb()
		task.spawn(function()
			while game:GetService("RunService").RenderStepped:Wait() do
				ret += (math.random(-2,2)/(if math.random(2) == 2 then 32 else 64)) - math.random(-1,1)/2
				task.wait(math.random(1,3)/90)
			end
		end)
		local h1;h1=hookmetamethod(game,"__namecall", function(...)
			local self = ...
			local method = getnamecallmethod():gsub("^%u", string.lower)

			if not checkcaller() and self == stats and method == "getTotalMemoryUsageMb" then
				return ret
			end

			self=nil
			return h1(...)
		end)
		local h2;h2=hookfunction(stats.GetTotalMemoryUsageMb, function(...)
			local self = ...
			if not checkcaller() and self == stats then
				return ret
			end

			self=nil
			return h2(...)
		end)
	end,

	getmem = function()
		return game:GetService("Stats"):GetTotalMemoryUsageMb()
	end,

	getmemtag = function(enum: EnumItem)
		return game:GetService("Stats"):GetMemoryUsageMbForTag(enum)
	end,

	setmeminflation = function(bool: boolean)
		local memconn = getgenv().meminflateconn

		if bool == false then
			if memconn then memconn:Disconnect() getgenv().meminflateconn = nil end
			return
		end

		getgenv().meminflateconn = game:GetService("RunService").Stepped:Connect(function()
			for i = 1, 100 do
				local part = Instance.new("Part")
				part.Parent = workspace

				local orient = Vector3.new(math.random(1, 360000)/100, math.random(1, 360000)/100, math.random(1, 360000)/100)
				part.Size = Vector3.new(2048,2048,2048)
				part.Orientation = orient
				part.Position = Vector3.new(9e9,9e9,9e9)
				part.Anchored = true
				part:Destroy()
			end
		end)
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
				for i = 1, 100 do
					local frame = Instance.new("Frame", game:GetService("CoreGui").RobloxGui)
					frame.Size = UDim2.new(20,0,20,0)
					frame.Position = UDim2.new(50,0,50,0)
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
					table.insert(getgenv().gcinflationtable or {}, table.create(150, ""))
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
				for i, v in getrenv() do if v == gtbl then target = v break end end
				istbl = true
			else
				return error("bad argument #1 to 'setvarintable' (table or string expected)")
			end
		end

		local unpacktbl = {unpack(target)}
		unpacktbl[varname] = nil

		if istbl then
			for i, v in getrenv() do
				if v == gtbl then
					getrenv()[i] = {
						[varname] = newvar, unpack(unpacktbl)
					}
					break
				end
			end
		else
			getrenv()[gtbl] = {
				[varname] = newvar, unpack(unpacktbl)
			}
		end
	end,

	disconn = function(conn)
		for i, v in next, getconnections(conn) do
			v:Disable()
		end
	end,

	spoofconns = if not (hookmetamethod and hookfunction) then nil else function(waithook: boolean)
		-- unfortunately unable to determine the connection to disconnect so this is for all connections
		-- do spoofconns(true/false) then disconn(examplesignal)
		local h;h=hookmetamethod(Instance.new("Part").Changed:Connect(function()end),"__index", function(...)
			local self, arg = ...
			if not checkcaller() and type(arg) == "string" and arg:gsub("^%u",string.lower) == "connected" or arg:gsub("^%u",string.lower):sub(1,10) == "connected\0" then
				return if waithook then pcall(function() wait(9e9) end) else true -- no wait(9e9) :(
			end
			self,arg=nil
			return h(...)
		end)
	end,

	clientran = function(scr: Instance)
		return scr.ClassName == "LocalScript" or (scr.ClassName == "Script" and scr.RunContext == Enum.RunContext.Client)
	end,

	serverran = function(scr: Instance)
		return scr.ClassName == "Script" and scr.RunContext ~= Enum.RunContext.Client
	end,

	antihttp = function(grabArgs: boolean)
		local _i = request or httprequest or http_request

		if not grabArgs then
			getgenv()[_i] = nil
		else
			getgenv()[_i] = function(tbl)
				warn("httprequest was triggered! Here are the arguments:")

				if type(tbl) == "table" then
					for i, v in pairs(tbl) do
						print(i, v)
					end
				else
					print(tbl)
				end

				warn("End of arguments")
			end
		end
	end,

	antiweaktable = if not getgc then nil else function()
		for i, v in getgc(true) do
			if type(v) == "table" and getrawmetatable(v) and type(getrawmetatable(v)) == "table" and type(rawget(getrawmetatable(v), "__mode")) == "string" and rawget(getrawmetatable(v), "__mode"):find("v") then
				if table.isfrozen(v) or table.isfrozen(getrawmetatable(v)) then continue end

				local var = rawget(getrawmetatable(v),"__mode")
				setmetatable(v,{
					__mode = var,
					__index = function()
						error("Don't worry about it ;)")
					end
				})
			end
		end
	end,

	antiweaktable2 = if not hookfunction then nil else function(checkMetaAmnt: boolean)
		local h; h = hookfunction(getrenv().setmetatable, function(...)
			local tbl1, tbl2 = ...

			if not checkcaller() and type(tbl1) == "table" and type(tbl2) == "table" and rawlen(tbl1) > 0 and (if checkMetaAmnt then rawlen(tbl2) == 1 else true) then
				local isMode = false
				local var = nil

				for i, v in pairs(tbl2) do -- Member table.foreachi is deprecated :(
					if i == "__mode" and type(v) == "string" and string.find(v, "v") then var = v; isMode = true end
				end

				if isMode then
					local res = h(...)

					local targetfnc = if not string.find(var, "k") then
						function()
							task.wait(math.random(5,8)/10)
							table.clear(res)
						end
						else
						function()
							task.wait(math.random(5,8)/10)
							for i, v in pairs(res) do
							if typeof(v) == "Instance" then
								rawset(res, i, nil)
							end
						end
						end

					task.spawn(targetfnc)
					return res
				end
			end

			tbl1,tbl2=nil,nil
			return h(...)
		end)
		for i, v in getgc(true) do
			if type(v) == "table" and getrawmetatable(v) and type(getrawmetatable(v)) == "table" and (rawget(getrawmetatable(v), "__mode") == "v" or rawget(getrawmetatable(v), "__mode") == "kv") then
				if table.isfrozen(v) then continue end

				task.wait()
				table.clear(v)
			end
		end
	end,

	antitostring = if not getgc then nil else function() -- fixing krnl decompiler detection i hope
		for i, v in getgc(true) do
			if type(v) == "table" and type(getrawmetatable(v)) == "table" and not table.isfrozen(v) and not table.isfrozen(getrawmetatable(v)) then
				if rawget(getrawmetatable(v),"__tostring") then
					table.clear(getrawmetatable(v))
				end
			end
		end
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
		local args = nil
		local h;h=hookfunction(rem.FireServer, function(...)
			args = {select(2,...)}
			return h(...)
		end)
		local h2;h2=hookmetamethod(game,"__namecall", function(...)
			local self = ...
			local method = getnamecallmethod():gsub("^%u", string.lower)

			if self == rem and method == "fireServer" then
				args = {select(2,...)}
			end
			self=nil

			return h2(...)
		end)
		while args == nil and task.wait() do end

		hookfunction(rem.FireServer, h)
		hookmetamethod(game,"__namecall", h2)

		return unpack(args)
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
			if type(v) == "table" and getmetatable(v) then
				table.insert(tbl, getmetatable(v))
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

	antikick = if not (hookmetamethod and hookfunction) then nil else function()
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

			self,arg = nil,nil
			return h1(...)
		end)

		local h2;h2=hookfunction(plr.Kick, function(...)
			local self, arg = ...

			if not checkcaller() and self == plr then
				if CanCastToSTDString(arg) then
					return wait(9e9)
				end
			end

			self,arg = nil,nil
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

	hookfs = if not (hookmetamethod and hookfunction) then nil else function(rem: RemoteEvent)
		local h1;h1=hookmetamethod(game,"__namecall", function(...)
			local self = ...
			local method = getnamecallmethod():gsub("^%u", string.lower)
			if not checkcaller() and self == rem and method == "fireServer" then
				return wait(9e9)
			end
			self=nil
			return h1(...)
		end)
		local h2;h2=hookfunction(rem.FireServer, function(...)
			local self = ...
			if not checkcaller() and self == rem then
				return wait(9e9)
			end
			self=nil
			return h2(...)
		end)
	end,

	hookis = if not (hookmetamethod and hookfunction) then nil else function(evn: RemoteFunction)
		local h1;h1=hookmetamethod(game,"__namecall", function(...)
			local self = ...
			local method = getnamecallmethod():gsub("^%u", string.lower)
			if not checkcaller() and self == evn and method == "invokeServer" then
				return wait(9e9)
			end
			self=nil
			return h1(...)
		end)
		local h2;h2=hookfunction(evn.InvokeServer, function(...)
			local self = ...
			if not checkcaller() and self == evn then
				return wait(9e9)
			end
			self=nil
			return h2(...)
		end)
	end,

	ls = function(url: string)
		return loadstring(game:HttpGet(url))()
	end,

	hookinscount = if not (hookmetamethod and hookfunction) then nil else function()
		local stats = game:GetService("Stats")
		local org = stats.InstanceCount
		task.spawn(function()
			while task.wait(.05) do
				org += math.random(-100, 101)
			end
		end)
		local h1;h1=hookmetamethod(game,"__index", function(...)
			local self, arg = ...
			if not checkcaller() and self == stats and type(arg) == "string" and (arg == "InstanceCount" or arg:sub(1,14) == "InstanceCount\0" or (not stats:FindFirstChild("instanceCount") and (arg == "instanceCount" or arg:sub(1,14) == "instanceCount\0"))) then
				return org
			end
			self,arg=nil,nil
			return h1(...)
		end)
	end,

	hookgs = if not (hookmetamethod and hookfunction) then nil else function(name: string, objtoreturn: Instance)
		local h1;h1=hookmetamethod(game,"__namecall", function(...)
			local self = ...
			local method = getnamecallmethod():gsub("^%u", string.lower)
			if not checkcaller() and self == game and method == "getService" then
				return objtoreturn or wait(9e9)
			end
			self=nil
			return h1(...)
		end)
		local h2;h2=hookfunction(game.GetService, function(...)
			local a,b = ...
			if not checkcaller() and a == game and b == name then
				return objtoreturn or wait(9e9)
			end
			a,b=nil,nil
			return h2(...)
		end)
	end,

	waithookfunc = if not hookfunction then nil else function(fnc)
		local h;h=hookfunction(fnc, function(...)
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

	loadsecuredex = function() -- warning: superly too many detection vectors possible for this, operate at your own risk

		-- Cloneref support (adds support for JJsploit/Temple/Electron and other sploits that don't have cloneref or really shit versions of it.)
		loadstring(game:HttpGet("https://raw.githubusercontent.com/Babyhamsta/RBLX_Scripts/main/Universal/CloneRef.lua", true))()

		-- Dex "Bypasses"
		loadstring(game:HttpGet("https://raw.githubusercontent.com/Babyhamsta/RBLX_Scripts/main/Universal/Bypasses.lua", true))()

		-- Dex with CloneRef Support (made as global)

		getgenv().Bypassed_Dex = game:GetObjects("rbxassetid://9352453730")[1]
		local Bypassed_Dex = Bypassed_Dex

		local charset = {}
		for i = 48,  57 do table.insert(charset, string.char(i)) end
		for i = 65,  90 do table.insert(charset, string.char(i)) end
		for i = 97, 122 do table.insert(charset, string.char(i)) end

		function RandomCharacters(length)
			if length > 0 then
				return RandomCharacters(length - 1) .. charset[math.random(1, #charset)]
			else
				return ""
			end
		end

		Bypassed_Dex.Name = RandomCharacters(math.random(5, 20))
		if gethui then
			Bypassed_Dex.Parent = gethui();
		elseif syn and syn.protect_gui then
			syn.protect_gui(Bypassed_Dex);
			Bypassed_Dex.Parent = cloneref(game:GetService("CoreGui"))
		else
			Bypassed_Dex.Parent = cloneref(game:GetService("CoreGui"))
		end

		local function Load(Obj, Url)
			local function GiveOwnGlobals(Func, Script)
				local Fenv = {}
				local RealFenv = {script = Script}
				local FenvMt = {}
				function FenvMt:__index(b)
					if RealFenv[b] == nil then
						return getfenv()[b]
					else
						return RealFenv[b]
					end
				end
				function FenvMt:__newindex(b, c)
					if RealFenv[b] == nil then
						getfenv()[b] = c
					else
						RealFenv[b] = c
					end
				end
				setmetatable(Fenv, FenvMt)
				setfenv(Func, Fenv)
				return Func
			end

			local function LoadScripts(Script)
				if Script.ClassName == "Script" or Script.ClassName == "LocalScript" then
					task.spawn(GiveOwnGlobals(loadstring(Script.Source, "=" .. Script:GetFullName()), Script))
				end
				for _,v in ipairs(Script:GetChildren()) do
					LoadScripts(v)
				end
			end

			LoadScripts(Obj)
		end

		Load(Bypassed_Dex)

	end,

	loaddex = function() -- prevents hooks from being used in secure dex so it's basically dex v3 with cloneref and little to no detections occur

		-- Cloneref support (adds support for JJsploit/Temple/Electron and other sploits that don't have cloneref or really shit versions of it.)
		loadstring(game:HttpGet("https://raw.githubusercontent.com/Babyhamsta/RBLX_Scripts/main/Universal/CloneRef.lua", true))()

		-- Dex Bypasses (nope! no detections for me please)

		-- Dex with CloneRef Support (made as global)
		getgenv().Bypassed_Dex = game:GetObjects("rbxassetid://9352453730")[1]
		local Bypassed_Dex = Bypassed_Dex

		local charset = {}
		for i = 48,  57 do table.insert(charset, string.char(i)) end
		for i = 65,  90 do table.insert(charset, string.char(i)) end
		for i = 97, 122 do table.insert(charset, string.char(i)) end
		function RandomCharacters(length)
			if length > 0 then
				return RandomCharacters(length - 1) .. charset[math.random(1, #charset)]
			else
				return ""
			end
		end

		Bypassed_Dex.Name = RandomCharacters(math.random(5, 20))
		if gethui then
			Bypassed_Dex.Parent = gethui();
		elseif syn and syn.protect_gui then
			syn.protect_gui(Bypassed_Dex);
			Bypassed_Dex.Parent = cloneref(game:GetService("CoreGui"))
		else
			Bypassed_Dex.Parent = cloneref(game:GetService("CoreGui"))
		end

		local function Load(Obj, Url)
			local function GiveOwnGlobals(Func, Script)
				local Fenv = {}
				local RealFenv = {script = Script}
				local FenvMt = {}
				function FenvMt:__index(b)
					if RealFenv[b] == nil then
						return getfenv()[b]
					else
						return RealFenv[b]
					end
				end
				function FenvMt:__newindex(b, c)
					if RealFenv[b] == nil then
						getfenv()[b] = c
					else
						RealFenv[b] = c
					end
				end
				setmetatable(Fenv, FenvMt)
				setfenv(Func, Fenv)
				return Func
			end

			local function LoadScripts(Script)
				if Script.ClassName == "Script" or Script.ClassName == "LocalScript" then
					task.spawn(GiveOwnGlobals(loadstring(Script.Source, "=" .. Script:GetFullName()), Script))
				end
				for _,v in ipairs(Script:GetChildren()) do
					LoadScripts(v)
				end
			end

			LoadScripts(Obj)
		end

		Load(Bypassed_Dex)

	end,

	loadtsdex = function() -- now this here is the real deal, this should be the preset for bypassing in-game anticheats with dex
		--[[
		this is meant to bypass almost every top-tier in-game anticheat out there
		if it does not bypass / is detected then it is your responsibility to bypass it yourself
		or
		dm @__europa
		(unless the detection is made by me lol)
		]]
		loadstring(game:HttpGet("https://raw.githubusercontent.com/FaithfulAC/universal-stuff/main/true-secure-dex-bypasses.lua"))()

		task.wait(.2)

		getgenv().Dex = game:GetObjects("rbxassetid://14878398926")[1]

		Dex.Parent = (gethui and gethui() ~= game:GetService("CoreGui") and gethui()) or (function()
			if syn and syn.protect_gui then
				syn.protect_gui(Dex)
			end
			return game:GetService("CoreGui").RobloxGui
		end)()

		-- lol silly forking
		local charset = {}
		for i = 48,  57 do table.insert(charset, string.char(i)) end
		for i = 65,  90 do table.insert(charset, string.char(i)) end
		for i = 97, 122 do table.insert(charset, string.char(i)) end
		function RandomCharacters(length)
			if length > 0 then
				return RandomCharacters(length - 1) .. charset[math.random(1, #charset)]
			else
				return ""
			end
		end
		Dex.Name = RandomCharacters(math.random(7,13))

		local function Load(Obj, Url)
			local function GiveOwnGlobals(Func, Script)
				local Fenv = {}
				local RealFenv = {script = Script}
				local FenvMt = {}
				function FenvMt:__index(b)
					if RealFenv[b] == nil then
						return getfenv()[b]
					else
						return RealFenv[b]
					end
				end
				function FenvMt:__newindex(b, c)
					if RealFenv[b] == nil then
						getfenv()[b] = c
					else
						RealFenv[b] = c
					end
				end
				setmetatable(Fenv, FenvMt)
				setfenv(Func, Fenv)
				return Func
			end

			local function LoadScripts(Script)
				if Script.ClassName == "Script" or Script.ClassName == "LocalScript" then
					task.spawn(GiveOwnGlobals(loadstring(Script.Source, "=" .. Script:GetFullName()), Script))
				end
				for _,v in ipairs(Script:GetChildren()) do
					LoadScripts(v)
				end
			end

			LoadScripts(Obj)
		end

		Load(Dex)
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
europa["rawinstanceequal"] = europa.rawinsequal
europa["replacehmm"] = europa.replacehookmetamethod
europa["getservice"] = europa.gs
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
europa["setvariableintable"] = europa.setvarintbl
europa["disconnect"] = europa.disconn
europa["spoofconnections"] = europa.spoofconns
europa["hookfireserver"] = europa.hookfs
europa["hookinvokeserver"] = europa.hookis
europa["hookgetservice"] = europa.hookgs
europa["quickload"] = europa.ls
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
europa["loadtruesecuredex"] = europa.loadtsdex
europa["loadsimplespy"] = europa.loadss
europa["loadvapev4"] = europa.loadv4
europa["rejoin"] = europa.rj

for i, v in europa do
	getgenv()[i] = v
end
