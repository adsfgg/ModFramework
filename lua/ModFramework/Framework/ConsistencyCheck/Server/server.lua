local kModName = debug.getinfo(1, "S").source:gsub("@lua/", ""):gsub("/Framework/.*%.lua", "")
local Mod = _G[kModName]
local serverEntryCount = 0
local clientEntryCount = 0

local function CompareEntries(client)
  assert(Server)
  assert(serverEntryCount > 0)
	assert(clientEntryCount > 0)

	if serverEntryCount ~= clientEntryCount then
    Server.DisconnectClient(client, "Entry file count mismatch")
	end
end

local function CheckServerEntry(client)
  local serverEntry = {}
	Shared.GetMatchingFileNames("lua/entry/*", true, serverEntry)
  serverEntryCount = #serverEntry
end

local function OnReceiveClientEntryCheck(client, message)
  clientEntryCount = message.count
	CompareEntries(client)
end

Event.Hook("ClientConnect", CheckServerEntry)
Server.HookNetworkMessage(Mod.config.kModName .. "_EntryCheck", OnReceiveClientEntryCheck)
