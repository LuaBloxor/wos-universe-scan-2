local Webhook = ""
local Anchor = GetPart("Anchor")
Anchor.Anchored=false
local Telescope = GetPart("Telescope")
local StarMap = GetPart("StarMap")
local Disk = GetPart("Disk")
local HyperDrive = GetPart("HyperDrive")
local Modem = GetPart("Modem")
local repr = require("repr")
local currentCoordinate = Telescope:GetCurrentCoordinate()
local systemId = tostring(currentCoordinate.UniverseCoordinates)
local running = coroutine.running()
local cancelThread
local function resume(...)
	if running and coroutine.status(running) == "suspended" then
		coroutine.resume(running, ...)
	end
end
Telescope:WhenRegionLoads(function(regionInfo)
	if cancelThread and coroutine.status(cancelThread) ~= "running" then
		task.cancel(cancelThread)
	end
	local info = Telescope:GetCoordinate()
	resume(regionInfo, info)
end)
local function Reading(coordinate)
	task.wait()
	Telescope.ViewCoordinates = coordinate
	cancelThread = task.delay(5, resume)
	return coroutine.yield()
end
local function SendMessage(content, endpoint)
	local response = Modem:RequestAsync({
		Method = "POST";
		Url = Webhook .. endpoint;
		Body = JSONEncode(content);
		Headers = {["Content-Type"] = "application/json"};
	})
	print(repr(response))
	if not response.Success then error(`{response.StatusCode}: {response.StatusMessage}`) end
	return response
end

print("started")
local regions = {}
local response = SendMessage({Location = systemId}, "mode")
local body = JSONDecode(response.Body)
local mode = body.Mode
print(mode)
if body.Message then
	print(body.Message)
end
if mode == "ScanUniverse" then
	for region, info in StarMap:GetSystems() do
		local regionInfo, extra = Reading(`{region}, 0, 0, false`)
		if not (regionInfo or extra) then print("no found", repr(info)) end
		regions[region] = {regionInfo, extra, info}
	end
	response = SendMessage({Systems = regions, Location = systemId}, "submit")
end
if mode == "ScanSolar" then
	for region, info in StarMap:GetBodies() do
		local regionInfo, extra = Reading(`{systemId}, {region}, false`)
		if not (regionInfo or extra) then print("no found", repr(info)) end
		regions[region] = {regionInfo, extra, info}
	end
	response = SendMessage({Bodies = regions, Location = systemId}, "submit")
end
local body = JSONDecode(response.Body)
if body.Message then
	print(body.Message)
end
if body.Finished then
	print(body.Finished)
	return
end
if not HyperDrive then
	print("no hyperdrive")
	return
end
HyperDrive.Coordinates = body.NextCoordinates
task.wait(3)
HyperDrive:Trigger()
