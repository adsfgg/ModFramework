function GetModConfig(kLogLevels)
	local config = {}

	config.kLogLevel = kLogLevels.debug
	config.kShowInFeedbackText = true
	config.kModVersion = "0"
	config.kModBuild = "1"

	config.modules =
	{
	}

	return config
end
