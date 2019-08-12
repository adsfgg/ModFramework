local Mod = GetMod()
local Utility = {}

-- Update value in enum
function Utility:UpdateEnum(tbl, key, value)
    local tblType = tbl and type(tbl) or "nil"

    assert(tblType == "table", "UpdateEnum: First argument expected to be of type table, was " .. tblType)
    assert(key, "UpdateEnum: Required second argument \"key\" missing.")
    assert(value, "UpdateEnum: Required third argument \"value\" missing.")

    assert(rawget(tbl, key), "UpdateEnum: key doesn't exist in table.")

    rawset(tbl, rawget(tbl, key), value)
    rawset(tbl, key, value)
end

-- Delete key from enum
function Utility:RemoveFromEnum(tbl, key)
    local tblType = tbl ~= nil and type(tbl) or "nil"

    assert(tblType == "table", "RemoveFromEnum: First argument expected to be of type table, was " .. tblType)
    assert(key ~= nil, "RemoveFromEnum: Required second argument \"key\" missing.")
    assert(rawget(tbl, key) ~= nil, "RemoveFromEnum: key doesn't exist in table.")

    rawset(tbl, rawget(tbl, key), nil)
    rawset(tbl, key, nil)

    local maxVal = 0
    if tbl == kTechId then
        maxVal = tbl.Max

        -- delete old max
        rawset(tbl, rawget(tbl, maxVal), nil)
        rawset(tbl, maxVal, nil)

        -- move max down
        rawset(tbl, 'Max', maxVal - 1)
        rawset(tbl, maxVal - 1, 'Max')
    end
end

function Utility:SendChatMessage(msg)
    local modName = Mod:GetModName()

    Server.SendNetworkMessage("Chat", BuildChatMessage(false, modName, -1, kTeamReadyRoom, kNeutralTeamType, msg), true)
    Shared.Message("Chat All - " .. modName .. ": " .. msg)
    Server.AddChatToHistory(msg, modName, 0, kTeamReadyRoom, false)
end

function Utility:CreateConsoleCommand(cmd, callback)
    assert(cmd, "Missing cmd argument.")
    assert(type(cmd) == "string", "Argument cmd not of correct type")

    assert(callback, "Missing callback argument")
    assert(type(callback) == "function", "Argument callback not of correct type.")

    local event = string.format("Console_%s_%s", Mod:GetModName():lower(), cmd)

    Event.Hook(event, callback)
end

function GetFrameworkModuleChanges()
    return "Utilities", Utility
end
