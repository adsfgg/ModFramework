if not string.find(Script.CallStack(), "Main.lua") then
    local kModName = debug.getinfo(1, "S").source:gsub("@lua/", ""):gsub("/Framework/.*%.lua", "")

    Script.Load("lua/Class.lua")
    Script.Load("lua/" .. kModName .. "/Framework/Framework.lua")

    local Mod = _G[kModName]

    Mod.Logger:PrintDebug("Loading NewScript files", "all")
    for i = 1, #Mod:GetModules() do
        local path = Mod:FormatDir(Mod:GetModules()[i], "NewScript")

        if Server then
            local hashPath = Mod:FormatDir(Mod.config.modules[i])
            local result = Server.AddRestrictedFileHashes(hashPath)
            Mod.Logger:PrintDebug("Hashing: " .. hashPath .. " Result: " .. (result and result or "nil"))
        end

        local NewScriptFiles = {}
        Shared.GetMatchingFileNames(path, true, NewScriptFiles)

        for j = 1, #NewScriptFiles do
            Mod.Logger:PrintDebug("Loading new tech file: " .. NewScriptFiles[j], "all")
            Script.Load(NewScriptFiles[j])
        end
    end

    Mod.Logger:PrintDebug("NewScript files loaded.", "all")

    Mod.Logger:PrintDebug("Loading Shared files", "all")

    for i = 1, #Mod:GetModules() do
        local path = Mod:FormatDir(Mod:GetModules()[i], "Shared")

        local SharedFiles = {}
        Shared.GetMatchingFileNames(path, true, SharedFiles)

        for j = 1, #SharedFiles do
            Mod.Logger:PrintDebug("Loading shared file: " .. SharedFiles[j], "all")
            Script.Load(SharedFiles[j])
        end
    end

    Mod.Logger:PrintDebug("Shared files loaded.", "all")
end
