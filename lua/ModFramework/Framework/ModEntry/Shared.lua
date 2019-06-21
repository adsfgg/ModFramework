local kModName = debug.getinfo(1, "S").source:gsub("@lua/", ""):gsub("/Framework/.*%.lua", "")

Script.Load("lua/Class.lua")
Script.Load("lua/" .. kModName .. "/Framework/Framework.lua")

local Mod = _G[kModName]

Mod.Logger:PrintDebug("Loading NewTech files", "all")
for i = 1, #Mod.config.modules do
	local path = Mod:FormatDir(Mod.config.modules[i], "NewTech")

	if Server then
		local hashPath = Mod:FormatDir(Mod.config.modules[i])
		local result = Server.AddRestrictedFileHashes(hashPath)
		Mod.Logger:PrintDebug("Hashing: " .. hashPath .. " Result: " .. (result and result or "nil"))
	end

	local NewTechFiles = {}
	Shared.GetMatchingFileNames(path, true, NewTechFiles)

	for i = 1, #NewTechFiles do
		Mod.Logger:PrintDebug("Loading new tech file: " .. NewTechFiles[i], "all")
		Script.Load(NewTechFiles[i])
	end
end

Mod.Logger:PrintDebug("NewTech files loaded.", "all")

Mod.Logger:PrintDebug("Loading Shared files", "all")

for i = 1, #Mod.config.modules do
	local path = Mod:FormatDir(Mod.config.modules[i], "Shared")

	local SharedFiles = {}
	Shared.GetMatchingFileNames(path, true, SharedFiles)

	for i = 1, #SharedFiles do
		Mod.Logger:PrintDebug("Loading shared file: " .. SharedFiles[i], "all")
		Script.Load(SharedFiles[i])
	end
end

Mod.Logger:PrintDebug("Shared files loaded.", "all")