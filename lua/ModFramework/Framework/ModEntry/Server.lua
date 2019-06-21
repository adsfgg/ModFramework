local Mod = GetMod()

local frameworkModules = Mod:GetFrameworkModules()
for i = 1, #frameworkModules do
	local path = Mod:FormatDir("Framework/" .. frameworkModules[i], "Server")

	local ServerFiles = {}
	Shared.GetMatchingFileNames(path, true, ServerFiles)

	for j = 1, #ServerFiles do
		Mod:PrintDebug("Loading server file: " .. ServerFiles[j], "Server")
		Script.Load(ServerFiles[j])
	end
end

Mod:PrintDebug("Loading Server files", "Server")

for i = 1, #Mod.config.modules do
	local path = Mod:FormatDir(Mod.config.modules[i], "Server")

	local ServerFiles = {}
	Shared.GetMatchingFileNames(path, true, ServerFiles)

	for i = 1, #ServerFiles do
		Mod:PrintDebug("Loading server file: " .. ServerFiles[i], "Server")
		Script.Load(ServerFiles[i])
	end
end

Mod:PrintDebug("Server files loaded.", "Server")

if Mod:GetConfig().disableRanking == true then
  gRankingDisabled = true
end

Mod:PrintVersion("Server")
