-- ok welp im probably going to discontinue this real quickly unless i figure out how to do this without env leaking in a debug info hook

local settings = (...) or { -- not much to add here
        Source = "ReplicatedFirst.",
        LookThroughTables = true,
        LookThroughUpvalues = true,
        HookPrintFunctions = true,
	ExtraFunctions = {}
}

local metamethods = {
        getrawmetatable(game).__namecall,
        getrawmetatable(game).__index,
        getrawmetatable(game).__newindex,
}

local function FunctionHandler(func, upvalueIndex)
	setupvalue(func, upvalueIndex --[[, ???]])
end

local function TableHandler(tbl, index)
	rawset(tbl, index --[[, ???]])
end

local data = {} -- not sure if this will even be needed, but whatevs
local garbage = getgc(true)

if settings.LookThroughUpvalues then
	for i, v in garbage do
		if typeof(v) == "function" and islclosure(v) then
			for _, item in getupvalues(v) do
				if table.find(metamethods, item) then
					table.insert(data, {
						
					})
				end
			end
		end
	end
end

if settings.LookThroughTables then
	for i, v in garbage do
		if typeof(v) == "table" and not rawequal(v, metamethods) then
			for _, metamethod in pairs(metamethods) do
				if table.find(v, metamethod) then
					table.insert(data, {
						
					})
				end
			end
		end
	end
end

garbage = nil;

local TostringHook;
TostringHook = hookfunction(getrenv().tostring, function(...) -- case people check tostring of original and compare it to the new replacement
        return TostringHook(...)
end)

local InfoHook;
InfoHook = hookfunction(getrenv().debug.info, function(...) -- case people retrieve the metamethod function
	local int = ...

	if typeof(int) == "number" and not InfoHook(int+1, "f") then
		return InfoHook(int+1, select(2,...)) -- if debug.info is being called for highest caller (this hook) then return nothing
	end
	
        return InfoHook(...)
end)

if settings.HookPrintFunctions then
        local PrintHook, WarnHook, ErrorHook;

        PrintHook = hookfunction(getrenv().print, function(...)
		return PrintHook(...)
	end)
        WarnHook = hookfunction(getrenv().warn, function(...)
		return WarnHook(...)
	end)
        ErrorHook = hookfunction(getrenv().error, function(...)
                return ErrorHook(...)
        end)
end
