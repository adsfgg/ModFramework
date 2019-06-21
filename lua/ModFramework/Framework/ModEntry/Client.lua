local Mod = GetMod()

Mod.Logger:PrintDebug("Loading Client files", "Client")

for i = 1, #Mod.config.modules do
	local path = Mod:FormatDir(Mod.config.modules[i], "Client")

	local ClientFiles = {}
	Shared.GetMatchingFileNames(path, true, ClientFiles)

	for j = 1, #ClientFiles do
		Mod.Logger:PrintDebug("Loading client file: " .. ClientFiles[j], "Client")
		Script.Load(ClientFiles[j])
	end
end

Mod.Logger:PrintDebug("Client files loaded.", "Client")

Mod.Logger:PrintVersion("Client")

if Mod:GetConfig().use_config == "client" or Mod:GetConfig().use_config == "both" then
	WriteDefaultConfigFile(Mod:GetConfigFileName(), Mod:GetDefaultConfigOptions())

	Mod:LoadConfig()
end
