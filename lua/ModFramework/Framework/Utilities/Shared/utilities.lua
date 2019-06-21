local Mod = GetMod()
local Utility = {}

local kModMaxRecursionDepth = 5

local function RecurseGetLocalVariable(self, originalFunction, localName, recurse, depth)
    if not depth then
        depth = 1
    else
        depth = depth + 1
    end
    local index = 1

    while true do

        local n, v = debug.getupvalue(originalFunction, index)
        if not n then
            break
        end

        if n == localName then
            return v
        end

        index = index + 1

    end

    if not recurse then return nil end

    -- recurse into local functions within the target function
    index = 1
    while true do
        local n,v = debug.getupvalue(originalFunction, index)

        if not n then break end

        local func

        if type(n) == "function" then
            func = n
        elseif type(v) == "function" then
            func = v
        end

        if func then
            -- make sure we don't recurse too far
            if depth + 1 > kModMaxRecursionDepth then
                self:Print("GetLocalVariable: Recursion depth exceeded.", self.kLogLevels.warn)
                return nil
            end

            local var = RecurseGetLocalVariable(self, func, localName, recurse, depth)
            if var ~= nil then
                return var
            end
        end

        index = index + 1
    end

    return nil
end

-- Get local variable from function
function Utility:GetLocalVariable(originalFunction, localName, recurse)
    local funcType = originalFunction and type(originalFunction) or "nil"
    local nameType = localName and type(localName) or "nil"
    local recurseType = recurse ~= nil and type(recurse) or "nil"

    assert(funcType == "function", "GetLocalVariable: Expected first argument to be of type function, was given " .. funcType)
    assert(nameType == "string", "GetLocalVariable: Expected second argument to be of type string, was given " .. nameType)
    assert(recurseType == "boolean" or recurseType == "nil", "GetLocalVariable: Expected optional fourth argument to be of type boolean, was given " .. recurseType)

    if recurse == nil then recurse = false end

    local var = RecurseGetLocalVariable(self, originalFunction, localName, recurse)
    if var == nil then
        self:Print("GetLocalVariable: Local variable \"" .. localName .. "\" not found", self.kLogLevels.warn)
    end
    return var
end

local function RecurseReplaceLocal(self, func, upName, newUp, recurse, depth)
    if not depth then
        depth = 1
    else
        depth = depth + 1
    end

    local index = 1
    -- check if this func has the up value first
    while true do
        local n,v = debug.getupvalue(func, index)

        if not n and not v then break end

        if n == upName then
            debug.setupvalue(func, index, newUp)
            return true
        end

        index = index + 1
    end

    if not recurse then return false end

    -- recurse into local functions within the target function
    index = 1
    while true do
        local n,v = debug.getupvalue(func, index)

        if not n then break end

        local func

        if type(n) == "function" then
            func = n
        elseif type(v) == "function" then
            func = v
        end

        if func then
            -- make sure we don't recurse too far
            if depth + 1 > kModMaxRecursionDepth then
                self:Print("ReplaceLocal: Recursion depth exceeded.", self.kLogLevels.warn)
                return false
            end

            local success = RecurseReplaceLocal(self, func, upName, newUp, recurse, depth)
            if success then
                return true
            end
        end

        index = index + 1
    end

    return false
end

function Utility:ReplaceLocal(func, upName, newUp, recurse)
    local funcType = func and type(func) or "nil"
    local upNameType = upName and type(upName) or "nil"
    local upFuncType = upFunc and type(upFunc) or "nil"
    local recurseType = recurse ~= nil and type(recurse) or "nil"

    assert(funcType == "function", "ReplaceLocal: Expected first argument to be of type function, was given " .. funcType)
    assert(upNameType == "string", "ReplaceLocal: Expected second argument to be of type string, was given " .. upNameType)
    assert(newUp ~= nil, "ReplaceLocal: Missing required third argument newUp.")
    assert(recurseType == "boolean" or recurseType == "nil", "ReplaceLocal: Expected optional fourth argument to be of type boolean, was given " .. recurseType)

    if recurse == nil then recurse = false end

    local success = RecurseReplaceLocal(self, func, upName, newUp, recurse)
    if not success then
        self:Print("ReplaceLocal: Local variable \"" .. upName .. "\" not found.", self.kLogLevels.warn)
    end
    return success
end

-- Append new value to enum
function Utility:AppendToEnum(tbl, key)
    local tblType = tbl and type(tbl) or "nil"

    assert(not techIdsLoaded or tbl ~= kTechId, "AppendToEnum: Do not use AppendToEnum to add tech ids. Define in config.lua")
    assert(tbl ~= nil and type(tbl) == "table", "AppendToEnum: First argument expected to be of type table, was " .. tblType)
    assert(key ~= nil, "AppendToEnum: required second argument \"key\" missing")
    assert(rawget(tbl,key) == nil, "AppendToEnum: key already exists in enum.")

    local maxVal = 0
    if tbl == kTechId then
        maxVal = tbl.Max

        -- delete old max
        rawset(tbl, rawget(tbl, maxVal), nil)
        rawset(tbl, maxVal, nil)

        -- move max down
        rawset(tbl, 'Max', maxVal+1)
        rawset(tbl, maxVal+1, 'Max')
    else
        for k, v in next, tbl do
            if type(v) == "number" and v > maxVal then
                maxVal = v
            end
        end
        maxVal = maxVal + 1
    end

    rawset(tbl, key, maxVal)
    rawset(tbl, maxVal, key)
end

-- Update value in enum
function Utility:UpdateEnum(tbl, key, value)
    local tblType = tbl and type(tbl) or "nil"

    assert(tblType == "table", "UpdateEnum: First argument expected to be of type table, was " .. tblType)
    assert(key, "UpdateEnum: Required second argument \"key\" missing.")
    assert(value, "UpdateEnum: Required third argument \"value\" missing.")

    assert(rawget(tbl,key), "UpdateEnum: key doesn't exist in table.")

    rawset(tbl, rawget(tbl, key), value)
    rawset(tbl, key, value)
end

-- Delete key from enum
function Utility:RemoveFromEnum(tbl, key)
    local tblType = tbl ~= nil and type(tbl) or "nil"

    assert(tblType == "table", "RemoveFromEnum: First argument expected to be of type table, was " .. tblType)
    assert(key ~= nil, "RemoveFromEnum: Required second argument \"key\" missing.")
    assert(rawget(tbl,key) ~= nil, "RemoveFromEnum: key doesn't exist in table.")

    rawset(tbl, rawget(tbl, key), nil)
    rawset(tbl, key, nil)

    local maxVal = 0
    if tbl == kTechId then
        maxVal = tbl.Max

        -- delete old max
        rawset(tbl, rawget(tbl, maxVal), nil)
        rawset(tbl, maxVal, nil)

        -- move max down
        rawset(tbl, 'Max', maxVal-1)
        rawset(tbl, maxVal-1, 'Max')
    end
end

-- Returns the relative ns2 path used to find lua files
function Utility:FormatDir(module, name, file)
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

function GetFrameworkModuleChanges()
    return "Utility", Utility
end
