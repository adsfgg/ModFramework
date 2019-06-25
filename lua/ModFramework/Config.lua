function GetModConfig(kLogLevels)
	local config = {}

	config.kLogLevel = kLogLevels.debug
	config.kShowInFeedbackText = false
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
