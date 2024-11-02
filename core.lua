-- GetSubZoneText() returns the name of the subzone the player is in, react on ZONE_CHANGED event
-- 

-- KillspeedTrackerDB = KillspeedTrackerDB or {}

-- You were defeated by 'Beth'tilac' after 3 minutes and 12 seconds.
-- You were victorious against 'Beth'tilac' after 3 minutes and 12 seconds.

local function initializeDB()
    KillspeedTrackedDB = {
        [720] = {
            [1203] = "Ragnaros",
            [1206] = "Alysrazor",
            [1205] = "Shannox",
            [1204] = "Lord Rhyolith",
            [1197] = "Beth'tilac",
            [1185] = "Majordomo Staghelm",
            [1200] = "Baleroc",
        },
        killTimes = {

        }
    }
end

local function formatKilltime(killtime) 
    if not killtime or killtime == 0 then
        return "N/A"
    end
    local minutes = math.floor(killtime / 60)
    local seconds = killtime % 60
    return string.format("%d:%02d", minutes, seconds)
end

local function getKilltimes()
    return string.format("Beth'tilac: %d\nLord Rhyolith: %d\nAlysrazor: %d\nShannox: %d\nBaleroc: %d\nMajordomo Staghelm: %d\nRagnaros: %d",
        formatKilltime(KillspeedTrackedDB.killTimes[1197]),
        formatKilltime(KillspeedTrackedDB.killTimes[1204]),
        formatKilltime(KillspeedTrackedDB.killTimes[1206]),
        formatKilltime(KillspeedTrackedDB.killTimes[1205]),
        formatKilltime(KillspeedTrackedDB.killTimes[1200]),
        formatKilltime(KillspeedTrackedDB.killTimes[1185]),
        formatKilltime(KillspeedTrackedDB.killTimes[1203])
    )
end


initializeDB()

print("Killspeed tracker loaded")

local encounterStartTime
local encounterEndTime

local mainFrame = CreateFrame("Frame", "KillspeedTrackerFrame", UIParent, 'BasicFrameTemplateWithInset')
mainFrame:SetSize(180, 150)
mainFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
mainFrame.TitleBg:SetHeight(30)
mainFrame.title = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
mainFrame.title:SetPoint("TOPLEFT", mainFrame.TitleBg, "TOPLEFT", 5, -3)
mainFrame.title:SetText("Killspeed Tracker")
mainFrame.body = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
mainFrame.body:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 10, -30)
mainFrame.body:SetText(getKilltimes())
mainFrame.body:SetJustifyH("LEFT")
mainFrame:EnableMouse(true)
mainFrame:SetMovable(true)
mainFrame:RegisterForDrag("LeftButton")
mainFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")

mainFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "ZONE_CHANGED_NEW_AREA" then
        if GetZoneText() == "Firelands" then
            mainFrame:RegisterEvent("ENCOUNTER_START")
            mainFrame:RegisterEvent("ENCOUNTER_END")
        else
            mainFrame:UnregisterEvent("ENCOUNTER_START")
            mainFrame:UnregisterEvent("ENCOUNTER_END")
        end
    end
    if event == "ENCOUNTER_START" then
        local encounterID, encounterName, difficultyID, groupSize = ...
        print('Encounter started: ' .. encounterName .. ' at ' .. GetServerTime())
        encounterStartTime = GetServerTime()
    elseif event == "ENCOUNTER_END" then
        local encounterID, encounterName, difficultyID, groupSize, success = ...
        print('Encounter ended: ' .. encounterName .. ' at ' .. GetServerTime())
        if success == 1 then
            encounterEndTime = GetServerTime()
            local encounterTime = encounterEndTime - encounterStartTime
            print('Encounter time: ' .. encounterTime)
            if not KillspeedTrackedDB.killTimes[encounterID] or KillspeedTrackedDB.killTimes[encounterID] > encounterTime then
                print('New best time for ' .. KillspeedTrackedDB[720][encounterID] .. ' with ' .. encounterTime .. ' seconds')
                KillspeedTrackedDB.killTimes[encounterID] = encounterTime
                mainFrame.body:SetText(getKilltimes())
            end
        else 
            print('You wiped on ' .. encounterName .. ' after ' .. encounterEndTime - encounterStartTime .. ' seconds')
        end
    end
end)

if GetZoneText() == "Firelands" then
    mainFrame:RegisterEvent("ENCOUNTER_START")
    mainFrame:RegisterEvent("ENCOUNTER_END")
end

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
        mainFrame.body:SetText(getKilltimes())
        mainFrame:Show()
    end
end

table.insert(UISpecialFrames, "KillspeedTrackerFrame")
