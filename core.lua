-- GetSubZoneText() returns the name of the subzone the player is in, react on ZONE_CHANGED event
-- 

-- KillspeedTrackerDB = KillspeedTrackerDB or {}

-- You were defeated by 'Beth'tilac' after 3 minutes and 12 seconds.
-- You were victorious against 'Beth'tilac' after 3 minutes and 12 seconds.

local function initializeDB()
    KillspeedTrackerDB = {
        [720] = {
            [52409] = "Ragnaros",
            [52530] = "Alysrazor",
            [53691] = "Shannox",
            [52558] = "Lord Rhyolith",
            [52498] = "Beth'tilac",
            [52571] = "Majordomo Staghelm",
            [53494] = "Baleroc",
        },
    }
end


initializeDB()

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
MyAddon:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
MyAddon:SetScript("OnEvent", function(self, event, ...)
    if event == "INSTANCE_ENCOUNTER_ENGAGE_UNIT" then
        for i = 1, MAX_BOSS_FRAMES do
            local guid = UnitGUID("boss"..i)
            if guid then
                -- Boss engaged
                local _, _, _, instance_id, _, npc_id, _ = strsplit("-", guid)
                print("Boss engaged: " ..guid)
                print(instance_id, npc_id)
                instance_id = tonumber(instance_id)
                npc_id = tonumber(npc_id)
                if not KillspeedTrackerDB[instance_id] then
                    print("Instance not found")
                    return
                end
                if not KillspeedTrackerDB[instance_id][npc_id] then
                    print("Boss not found")
                    return
                end
                print("Boss engaged: "..KillspeedTrackerDB[instance_id][npc_id])
                return
            end
        end
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, subEvent, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags, _, spellID, spellName = CombatLogGetCurrentEventInfo()
        if subEvent == "UNIT_DIED" then
            local _, _, _, instance_id, _, npc_id, _ = strsplit("-", destGUID)
            instance_id = tonumber(instance_id)
            npc_id = tonumber(npc_id)
            if not KillspeedTrackerDB[instance_id] then
                print("Instance not found")
                return
            end
            if not KillspeedTrackerDB[instance_id][npc_id] then
                print("Boss not found")
                return
            end
            print("Boss died: "..KillspeedTrackerDB[instance_id][npc_id])
        end
    end
    
end)

table.insert(UISpecialFrames, "KillspeedTrackerFrame")