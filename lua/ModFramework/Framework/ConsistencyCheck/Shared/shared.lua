local Mod = GetMod()
local kMaxEntryFiles = 100

Shared.RegisterNetworkMessage(Mod.config.kModName .. "_EntryCheck", {
  count = string.format("integer (0 to %d)", kMaxEntryFiles),
})
