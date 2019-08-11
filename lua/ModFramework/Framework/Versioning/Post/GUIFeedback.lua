local Mod = GetMod()

if Mod:GetConfig().kShowInFeedbackText then

    local originalFeedbackInit

    originalFeedbackInit = Class_ReplaceMethod("GUIFeedback", "Initialize",
            function(self)
                originalFeedbackInit(self)
                self.buildText:SetText(self.buildText:GetText() .. Mod.Versioning:GetFeedbackText())
            end)

end
