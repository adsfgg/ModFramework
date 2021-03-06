Script.Load("lua/%__MODNAME__%/ModFramework/ModFramework.lua")

local function FormatDir(fw, module, hookType)
    return string.format("lua/%s/Modules/%s/%s/*.lua", fw:GetModName(), module, hookType)
end

local mod = ModFramework
mod:Initialize("FileHook", true)
mod:InitModules()
mod:LoadAllModuleFiles("FileHook")

local moduleManager = mod:GetModule('modulemanager')
local logger = mod:GetModule('logger')
local modules = moduleManager:GetModules()

for _,module in ipairs(modules) do
    local types = { "Halt", "Post", "Pre", "Replace" }

    for _,hookType in ipairs(types) do
        local path = FormatDir(mod, module, hookType)
        local files = {}

        Shared.GetMatchingFileNames(path, true, files)

        for _,file in ipairs(files) do
            local vpath = file:gsub(mod:GetModName() .. "/.*/" .. hookType .. "/", "")

            logger:PrintDebug("Hooking file: %s, Vanilla Path: %s, Method: %s", file, vpath, hookType)
            ModLoader.SetupFileHook(vpath, file, hookType:lower())
        end
    end
end
