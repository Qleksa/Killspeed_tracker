-- GetSubZoneText() returns the name of the subzone the player is in, react on ZONE_CHANGED event
-- 
local function initializeDB()
    KillspeedTrackedDB = {
        FirelandsBosses = {
            [52409] = "Ragnaros",
            [52530] = "Alysrazor",
            [53691] = "Shannox",
            [52558] = "Lord Rhyolith",
            [52498] = "Beth'tilac",
            [52571] = "Majordomo Staghelm",
            [53494] = "Baleroc",
        },
        FirelandsBossSubZones = {
            ["Sulfuron Keep"] = 52409, -- Ragnaros
            ["Path of the Phoenix"] = 52530, -- Alysrazor
            ["Ridge of the Ember Lord"] = 53691, -- Shannox
            ["The Scorched Plain"] = 52558, -- Lord Rhyolith
            ["Beth'tilac's Lair"] = 52498, -- Beth'tilac
            ["Forge of Flames"] = 52571, -- Majordomo Staghelm
            ["Bridge of Flame"] = 53494, -- Baleroc
        }
    }
end


if not KillspeedTrackerDB then
    initializeDB()
end

print("Killspeed tracker loaded")

local mainFrame = CreateFrame("Frame", "KillspeedTrackerFrame", UIParent, "BasicFrameTemplateWithInset")
mainFrame:SetSize(500, 350)
mainFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
mainFrame.TitleBg:SetHeight(30)
mainFrame.title = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
mainFrame.title:SetPoint("TOPLEFT", mainFrame.TitleBg, "TOPLEFT", 5, -3)
mainFrame.title:SetText("Killspeed Tracker")
mainFrame:EnableMouse(true)
mainFrame:SetMovable(true)
mainFrame:RegisterForDrag("LeftButton")

mainFrame:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)

mainFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
end)

mainFrame:Hide()

SLASH_KILLSPEED_TRACKER1 = "/kst"
SlashCmdList["KILLSPEED_TRACKER"] = function ()
    if mainFrame:IsShown() then
        mainFrame:Hide()
    else
        mainFrame:Show()
    end
end

-- test
local MyAddon = CreateFrame("Frame")
MyAddon:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
MyAddon:SetScript("OnEvent", function(self, event, ...)
    for i = 1, MAX_BOSS_FRAMES do
        local guid = UnitGUID("boss"..i)
        if guid then
            -- Boss engaged
            print("Encounter started with boss: " .. guid)
            return
        end
    end
end)

table.insert(UISpecialFrames, "KillspeedTrackerFrame")