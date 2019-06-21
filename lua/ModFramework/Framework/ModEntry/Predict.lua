local Mod = GetMod()

Mod.Logger:PrintDebug("Loading Predict files", "Predict")

for i = 1, #Mod.config.modules do
	local path = Mod:FormatDir(Mod.config.modules[i], "Predict")

	local PredictFiles = {}
	Shared.GetMatchingFileNames(path, true, PredictFiles)

	for i = 1, #PredictFiles do
		Mod.Logger:PrintDebug("Loading predict file: " .. PredictFiles[i], "Predict")
		Script.Load(PredictFiles[i])
	end
end

Mod.Logger:PrintDebug("Predict files loaded.", "Predict")
