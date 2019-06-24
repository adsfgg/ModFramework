local framework_version = "0"
local framework_build = "20.2"

local frameworkModules = {
  "Utilities",
  "Bindings",
  "ConsistencyCheck",
  "ResourceSystem",
  "TechChanges",
}

local Mod = {}
local kModName = "Mod"

function Mod:ValidateModule(name, value)
  return name and value and type(name) == "string" and type(value) == "table"
end

local function FindModName()
  local modName = debug.getinfo(1, "S").source:gsub("@lua/", ""):gsub("/Framework/.*%.lua", "")
  assert(modName and type(modName) == "string", "Error finding mod name. Please report.")
  return modName
end

function GetMod()
  return Mod
end

local function LoadSharedFiles(module, p)
  local path = Mod:FormatDir("Framework/" .. module, "Shared")

  local SharedFiles = {}
  Shared.GetMatchingFileNames(path, true, SharedFiles)

  for j = 1, #SharedFiles do
    p(string.format("Loading shared file: %s", SharedFiles[j]))
    Script.Load(SharedFiles[j])
    if GetFrameworkModuleChanges then
      local name, value = GetFrameworkModuleChanges()
      GetFrameworkModuleChanges = nil

      if Mod:ValidateModule(name, value) then
        p(string.format("Integrating module: %s", name))
        Mod[name] = value
      else
        p(string.format("Not integrating module %s. Invalid module.", name))
      end
    end
  end
end

local function SetupFileHooks(module, p)
  local currentModule = "Framework/" .. module
  local types = { "Halt", "Post", "Pre", "Replace" }

  for j = 1, #types do
    local hookType = types[j]
    local path = Mod:FormatDir(currentModule, hookType)
    local files = {}

    Shared.GetMatchingFileNames(path, true, files)

    for k = 1, #files do
      local file = files[k]
      local vpath = file:gsub(kModName .. "/.*/" .. hookType .. "/", "")

      p(string.format("Hooking file: %s, Vanilla Path: %s, Method: %s", file, vpath, hookType), "all")
      ModLoader.SetupFileHook(vpath, file, hookType:lower())
    end
  end
end

local function LoadClientScripts(module, p)
  local path = Mod:FormatDir("Framework/" .. module, "Client")

  local ClientFiles = {}
  Shared.GetMatchingFileNames(path, true, ClientFiles)

  for j = 1, #ClientFiles do
    p(string.format("Loading client file: %s", ClientFiles[j]))
    Script.Load(ClientFiles[j])
  end
end

local function LoadServerScripts(module, p)
  local path = Mod:FormatDir("Framework/" .. module, "Server")

  local ServerFiles = {}
  Shared.GetMatchingFileNames(path, true, ServerFiles)

  for j = 1, #ServerFiles do
    p(string.format("Loading server file: %s", ServerFiles[j]))
    Script.Load(ServerFiles[j])
  end
end

local function LoadPredictScripts(module, p)
  local path = Mod:FormatDir("Framework/" .. module, "Predict")

  local PredictFiles = {}
  Shared.GetMatchingFileNames(path, true, PredictFiles)

  for j = 1, #PredictFiles do
    p("Loading predict file: %s", PredictFiles[j])
    Script.Load(PredictFiles[j])
  end
end

local function LoadFrameworkModule(module, hasLogging)
  local p
  if hasLogging == nil then hasLogging = Mod.Logger ~= nil end

  -- logging might not have been setup at this point
  if hasLogging then
    p = function(str) Mod.Logger:PrintDebug(str) end
  else
    local vm = Client and "Client" or Server and "Server" or Predict and "Predict" or "None"
    p = function(str) print(string.format("[%s - %s] %s", kModName, vm, str)) end
  end

  p("Loading framework module: " .. module)

  -- load shared
  LoadSharedFiles(module, p)

  -- setup filehooks
  SetupFileHooks(module, p)

  -- load individual vm scripts
  if Client then
    LoadClientScripts(module, p)
  elseif Server then
    LoadServerScripts(module, p)
  elseif Predict then
    LoadPredictScripts(module, p)
  end
end

function Mod:Initialise()
  kModName = FindModName()
  local current_vm = Client and "Client" or Server and "Server" or Predict and "Predict" or "Unknown"

  Shared.Message(string.format("[%s - %s] Loading framework %s", kModName, current_vm, self:GetFrameworkVersionPrintable()))

  if _G[kModName] then
    Mod = _G[kModName]
    Mod.Logger:PrintInfo(string.format("Skipped loading framework %s", self:GetFrameworkVersionPrintable()))
    return
  end

  LoadFrameworkModule("Logging", false)

  Script.Load("lua/" .. kModName .. "/Config.lua")

  local config = assert(GetModConfig, "Initialise: Config.lua malformed. Missing GetModConfig function.")
  config = config(self.Logger:GetLogLevels())

  assert(config, "Initialise: Config.lua malformed. GetModConfig doesn't return anything.")
  assert(type(config) == "table", "Initialise: Config.lua malformed. GetModConfig doesn't return expected type.")

  Script.Load("lua/" .. kModName .. "/Framework/ConfigValidation.lua")

  valid, reason = RunFrameworkValidator(config)
  assert(valid, "Initialise: Config failed validation. " .. reason)

  config.kModName = kModName
  self.config, config = config, nil

  for _,v in ipairs(frameworkModules) do
    LoadFrameworkModule(v, true)
  end

  _G[kModName] = self
   Shared.Message(string.format("[%s - %s] Framework %s loaded", kModName, current_vm, self:GetFrameworkVersionPrintable()))
end

function Mod:GetFrameworkModules()
  return frameworkModules
end

-- Returns a string with the mod version
function Mod:GetVersion()
  return string.format("v%s.%s", self.config.kModVersion, self.config.kModBuild);
end

function Mod:GetFrameworkVersion()
  return framework_version
end

function Mod:GetFrameworkBuild()
  return framework_build
end

function Mod:GetFrameworkVersionPrintable()
  return string.format("v%s.%s", self:GetFrameworkVersion(), self:GetFrameworkBuild())
end

function Mod:GetConfig()
  return self.config
end

function Mod:GetConfigLogLevel()
  return self.config.kLogLevel
end

function Mod:GetModName()
  return kModName
end

-- Returns the relative ns2 path used to find lua files
function Mod:FormatDir(module, name, file)
  local moduleType = module and type(module) or "nil"
  assert(moduleType == "string", "FormatDir: First argument expected to be of type string, was " .. moduleType)

  if name then
    if file then
      return string.format("lua/%s/%s/%s.lua", kModName, module, name)
    else
      return string.format("lua/%s/%s/%s/*.lua", kModName, module, name)
    end
  else
    return string.format("lua/%s/%s/*.lua", kModName, module)
  end
end

--[[
========================
      Helper Funcs
========================
]]

-- i wish the # operator was deterministic
function table.real_length(tbl)
  local count = 0
  for k,v in pairs(tbl) do
    count = count + 1
  end
  return count
end

function table.contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

--[[
====================
    Config Funcs
====================
]]

local configOptions = {}
local defaultConfigOptions = {}

function Mod:GetConfigFileName()
  local modName = self:GetModName()

  if Server then
    return modName .. "_Server.json"
  end

  return modName .. ".json"
end

function Mod:RegisterConfigOption(name, value)
  assert(not configOptions[name], string.format("RegisterConfigOption: %q is already registered", name))
  defaultConfigOptions[name] = value
end

function Mod:GetDefaultConfigOptions()
  return defaultConfigOptions
end

function Mod:GetConfigOption(name)
  assert(configOptions[name], string.format("GetConfigOption: No config option with the name %q is registered", name))
  return configOptions[name]
end

function Mod:UpdateConfigOption(name, value)
  assert(configOptions[name], string.format("UpdateConfigOption: No config option with the name %q is registered", name))
  configOptions[name] = value
  self:SaveConfigOptions()
end

function Mod:SaveConfigOptions()
  SaveConfigFile(self:GetConfigFileName(), configOptions)
end

function Mod:LoadConfig()
  configOptions = LoadConfigFile(self:GetConfigFileName()) or defaultConfigOptions
end

-- We're finally done
-- Init the stuff

Mod:Initialise()
