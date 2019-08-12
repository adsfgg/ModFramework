local Mod = GetMod()
local ScriptLoader = {}

local function ValidateLoadScript(module, scriptName)
    local moduleType = module and type(module) or "nil"
    assert(module, "Missing required argument: module")
    assert(moduleType == "string", "Argument module not of correct type. Expected string got " .. moduleType)
    moduleType = nil

    local scriptNameType = scriptName and type(scriptName) or "nil"
    assert(scriptName, "Missing required argument: scriptName")
    assert(scriptNameType == "string", "Argument scriptName not of correct type. Expected string got " .. scriptNameType)
    scriptNameType = nil

    return true
end

function ScriptLoader:LoadScript(module, scriptName)
    if ValidateLoadScript(module, scriptName) then
        scriptName = "Scripts/" .. scriptName
        module = "Modules/" .. module
        local scriptPath = Mod:FormatDir(module, scriptName, true)
        if Server then
            local hashPath = Mod:FormatDir(module)
            local result = Server.AddRestrictedFileHashes(hashPath)
            Mod.Logger:PrintDebug("Hashing: " .. hashPath .. " Result: " .. (result and result or "nil"))
        end
        Script.Load(scriptPath)
        Mod.Logger:PrintDebug("Loaded Script file " .. scriptPath)
    end
end

function GetFrameworkModuleChanges()
    return "ScriptLoader", ScriptLoader
end
