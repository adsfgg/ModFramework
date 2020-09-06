--[[
    This is the main config file for your mod.

    For information on how to use this file see the wiki.
]]

function GetModFrameworkConfig%__MODNAME__%()
    -- Main config
    local config = {}
    
    -- Logger
    config.logger = {}
    config.logger.enabled = true
    config.logger.level = "debug"
    
    -- Versioning
    config.versioning = {}
    config.versioning.majorVersion = 0
    config.versioning.minorVersion = 1
    config.versioning.patchVersion = 0
    config.versioning.preRelease = ""
    config.versioning.display = true
    
    -- Tech Handler
    config.techhandler = {}
    config.techhandler.techIdsToAdd = {}
    
    return config
end
