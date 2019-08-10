local Config = {}

function GetModConfig(kLogLevels)
	local config = {}

	config.kLogLevel = kLogLevels.debug
	config.kShowInFeedbackText = false
	config.disableRanking = false
	config.use_config = "none"
	config.techIdsToAdd = Config.GetTechIdsToAdd()

	config.libraries = Config.GetLibraries()

	config.modules = Config.GetModules()

	return config
end

function GetVersionInformation(Versioning)
	Versioning:SetVersion(1, 2, 3, "rc1")
end

function Config:GetTechIdsToAdd()
	return {

	}
end

function Config:GetLibraries()
	return {

	}
end

function Config:GetModules()
	return {

	}
end