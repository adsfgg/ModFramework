ModFramework.ModConfig:RegisterConfigOption("testvalue", 12)
local function test(a)
    assert(a)
    ModFramework.ModConfig:UpdateConfigOption("testvalue", a)
    ModFramework.ModConfig:SaveConfigOptions()
end

ModFramework.Utilities:CreateConsoleCommand("test", test)
Event.Hook("Console_compmod_test", test)