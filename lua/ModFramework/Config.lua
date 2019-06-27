function GetModConfig(kLogLevels)
	local config = {}

	config.kLogLevel = kLogLevels.debug
	config.kShowInFeedbackText = true
	config.kModVersion = "0"
	config.kModBuild = "1"
	config.disableRanking = false
	config.use_config = "none"
	config.techIdsToAdd = {
	}

	config.libraries = {
	}

	config.modules = {
	}

	return config
end

function GetVersionInformation(Versioning)
	Versioning:SetVersion(1, 2, 3, "rc1")
end