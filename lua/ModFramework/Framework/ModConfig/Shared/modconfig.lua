local Mod = GetMod()
local ModConfig = {}

local configOptions = {}
local defaultConfigOptions = {}
local loaded = false

local function CheckVM()
    local allowed_vms = Mod:GetConfig().use_config
    local assert_text = "Cannot use ModConfig functions on %s VM. If you want to use a config on this VM please specify in Config.lua"

    -- assert(Predict, "Cannot use ModConfig functions on Predict VM.")

    -- if we don't allow both server and client then we need to check them individually.
    if assert_text ~= "all" then
        if Client then
            assert(allowed_vms == "client", string.format(assert_text, "Client"))
        end

        if Server then
            assert(Server and allowed_vms == "server", string.format(assert_text, "Server"))
        end
    end
end

function ModConfig:GetConfigFileName()
    CheckVM()
    local modName = Mod:GetModName()

    if Server then
        return modName .. "_Server.json"
    end

    return modName .. ".json"
end

function ModConfig:RegisterConfigOption(name, value)
    CheckVM()
    assert(not loaded, "Cannot register a new config option after the config has loaded.")
    assert(not defaultConfigOptions[name], string.format("RegisterConfigOption: %q is already registered", name))
    defaultConfigOptions[name] = value
end

function ModConfig:GetDefaultConfigOptions()
    CheckVM()
    return defaultConfigOptions
end

function ModConfig:GetConfigOption(name)
    CheckVM()
    assert(loaded, "Cannot get a config option before the current options are loaded.")
    assert(defaultConfigOptions[name], string.format("GetConfigOption: No config option with the name %q is registered", name))
    return configOptions[name]
end

function ModConfig:UpdateConfigOption(name, value)
    CheckVM()
    assert(loaded, "Cannot update a config option before the current options are loaded.")
    assert(defaultConfigOptions[name], string.format("UpdateConfigOption: No config option with the name %q is registered", name))
    configOptions[name] = value
    self:SaveConfigOptions()
end

function ModConfig:SaveConfigOptions()
    CheckVM()
    SaveConfigFile(self:GetConfigFileName(), configOptions)
end

function ModConfig:LoadConfig()
    CheckVM()
    loaded = true
    configOptions = LoadConfigFile(self:GetConfigFileName()) or defaultConfigOptions
end

function GetFrameworkModuleChanges()
    return "ModConfig", ModConfig
end