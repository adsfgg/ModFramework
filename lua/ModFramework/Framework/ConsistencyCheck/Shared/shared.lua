local kModName = debug.getinfo(1, "S").source:gsub("@lua/", ""):gsub("/Framework/.*%.lua", "")
local Mod = _G[kModName]
local kMaxEntryFiles = 100

Shared.RegisterNetworkMessage(Mod.config.kModName .. "_EntryCheck", {
  count = string.format("integer (0 to %d)", kMaxEntryFiles),
})
