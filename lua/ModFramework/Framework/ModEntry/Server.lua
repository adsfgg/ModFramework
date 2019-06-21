local Mod = GetMod()

Mod.Logger:PrintDebug("Loading Server files", "Server")

for i = 1, #Mod.config.modules do
	local path = Mod:FormatDir(Mod.config.modules[i], "Server")

	local ServerFiles = {}
	Shared.GetMatchingFileNames(path, true, ServerFiles)

	for i = 1, #ServerFiles do
		Mod.Logger:PrintDebug("Loading server file: " .. ServerFiles[i], "Server")
		Script.Load(ServerFiles[i])
	end
end

Mod.Logger:PrintDebug("Server files loaded.", "Server")

if Mod:GetConfig().disableRanking == true then
  gRankingDisabled = true
end

Mod.Logger:PrintVersion("Server")
