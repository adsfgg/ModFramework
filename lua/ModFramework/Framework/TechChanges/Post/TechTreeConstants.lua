local Mod = GetMod()

-- Table for new tech names
local newTechNames = Mod.Tech:GetTechIdsToAdd()

for _,v in ipairs(newTechNames) do
  Mod.Utilities:AppendToEnum(kTechId, v)
end
