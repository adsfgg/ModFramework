local kModName = debug.getinfo(1, "S").source:gsub("@lua/", ""):gsub("/Framework/.*%.lua", "")

Script.Load("lua/Class.lua")
Script.Load("lua/" .. kModName .. "/Framework/Framework.lua")

local Mod = _G[kModName]

local frameworkModules = Mod:GetFrameworkModules()
for i = 1, #frameworkModules do
	local path = Mod:FormatDir("Framework/" .. frameworkModules[i], "Shared")

	local SharedFiles = {}
	Shared.GetMatchingFileNames(path, true, SharedFiles)

	for j = 1, #SharedFiles do
		Mod:PrintDebug("Loading shared file: " .. SharedFiles[j], "all")
		Script.Load(SharedFiles[j])
		if GetFrameworkModuleChanges then
			local name, value = GetFrameworkModuleChanges()
			GetFrameworkModuleChanges = nil

			if Mod:ValidateModule(name, value) then
				Mod:PrintDebug("Integrating module: " .. name)
				_G[kModName][name] = value
			else
				Mod:PrintDebug(string.format("Not integrating module %s. Checks fail.", name))
			end
		end
	end
end

Mod:PrintDebug("Loading NewTech files", "all")
for i = 1, #Mod.config.modules do
	local path = Mod:FormatDir(Mod.config.modules[i], "NewTech")

	if Server then
		local hashPath = Mod:FormatDir(Mod.config.modules[i])
		local result = Server.AddRestrictedFileHashes(hashPath)
		Mod:PrintDebug("Hashing: " .. hashPath .. " Result: " .. (result and result or "nil"))
	end

	local NewTechFiles = {}
	Shared.GetMatchingFileNames(path, true, NewTechFiles)

	for i = 1, #NewTechFiles do
		Mod:PrintDebug("Loading new tech file: " .. NewTechFiles[i], "all")
		Script.Load(NewTechFiles[i])
	end
end

Mod:PrintDebug("NewTech files loaded.", "all")

Mod:PrintDebug("Loading Shared files", "all")

for i = 1, #Mod.config.modules do
	local path = Mod:FormatDir(Mod.config.modules[i], "Shared")

	local SharedFiles = {}
	Shared.GetMatchingFileNames(path, true, SharedFiles)

	for i = 1, #SharedFiles do
		Mod:PrintDebug("Loading shared file: " .. SharedFiles[i], "all")
		Script.Load(SharedFiles[i])
	end
end

Mod:PrintDebug("Shared files loaded.", "all")
