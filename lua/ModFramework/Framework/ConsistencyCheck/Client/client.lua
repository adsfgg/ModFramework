local kModName = debug.getinfo(1, "S").source:gsub("@lua/", ""):gsub("/Framework/.*%.lua", "")
local Mod = _G[kModName]
local sent = false

local function CheckClientEntry()
	if sent then return end

  local clientEntry = {}

	Shared.GetMatchingFileNames("lua/entry/*", true, clientEntry)

	Client.SendNetworkMessage(Mod.config.kModName .. "_EntryCheck", {count = #clientEntry}, true)

	sent = true
end

Event.Hook("UpdateClient", CheckClientEntry)
