function GetModConfig(kLogLevels)
	local config = {}

	config.kLogLevel = kLogLevels.debug
	config.kShowInFeedbackText = false
	config.kModVersion = "0"
	config.kModBuild = "1"
	config.disableRanking = false
	
	config.modules =
	{
	}

	return config
end
