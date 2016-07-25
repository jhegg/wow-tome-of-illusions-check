local addonName, _ = ...

TomeOfIllusionsCheck = {
  name = addonName,
  version = GetAddOnMetadata(addonName, "Version"),
  author = GetAddOnMetadata(addonName, "Author"),
  missingItemData = {},
  tomesToQuests = {
     [138795] = 42879, -- Tome of Illusions: Draenor
     [138793] = 42877, -- Tome of Illusions: Pandaria
     [138794] = 42878, -- Tome of Illusions: Secrets of the Shado-pan
     [138791] = 42875, -- Tome of Illusions: Cataclysm
     [138792] = 42876, -- Tome of Illusions: Elemental Lords
     [138790] = 42874, -- Tome of Illusions: Northrend
     [138789] = 42873, -- Tome of Illusions: Outland
     [138787] = 42871, -- Tome of Illusions: Azeroth
  },
}

TomeOfIllusionsCheck.addon = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceEvent-3.0")
local addon = TomeOfIllusionsCheck.addon

-- Courtesy of http://www.lua.org/pil/19.3.html
local function pairsByKeys(t, f)
   local a = {}
   for n in pairs(t) do table.insert(a, n) end
   table.sort(a, f)
   local i = 0      -- iterator variable
   local iter = function ()   -- iterator function
      i = i + 1
      if a[i] == nil then return nil
      else return a[i], t[a[i]]
      end
   end
   return iter
end

SLASH_TomeOfIllusionsCheck1 = "/tomecheck"

SlashCmdList["TomeOfIllusionsCheck"] = function()
  TomeOfIllusionsCheck:CheckItemCache()
  if #TomeOfIllusionsCheck.missingItemData == 0 then
    TomeOfIllusionsCheck:PrintTomeCheck()
  end
end

local function itemInfoReceived()
  for key, itemId in pairs(TomeOfIllusionsCheck.missingItemData) do
    local itemName, _, _, _, _, _, _, _, _, _, _ = GetItemInfo(itemId)
    if itemName then
      tremove(TomeOfIllusionsCheck.missingItemData, key)
    end
  end

  if #TomeOfIllusionsCheck.missingItemData == 0 then
    addon:UnregisterEvent("GET_ITEM_INFO_RECEIVED")
    TomeOfIllusionsCheck:PrintTomeCheck()
  end
end

function TomeOfIllusionsCheck:CheckItemCache()
  for itemId, questId in pairs(TomeOfIllusionsCheck.tomesToQuests) do
     local itemName, _, _, _, _, _, _, _, _, _, _ = GetItemInfo(itemId)
     if not itemName then
       tinsert(TomeOfIllusionsCheck.missingItemData, itemId)
       addon:RegisterEvent("GET_ITEM_INFO_RECEIVED", itemInfoReceived)
     end
  end
end

function TomeOfIllusionsCheck:PrintTomeCheck()
  local tomesByName = {}
  for itemId, questId in pairs(TomeOfIllusionsCheck.tomesToQuests) do
    local itemName, itemLink, _, _, _, _, _, _, _, _, _ = GetItemInfo(itemId)
    tomesByName[itemName] = {
      questId = questId,
      itemLink = itemLink,
    }
  end
  table.sort(tomesByName)

  print(addonName)
  for itemName, itemInfo in pairsByKeys(tomesByName) do
    local questStatus = IsQuestFlaggedCompleted(itemInfo.questId) and "Known" or "Unknown"
    print(format("%s - %s", itemInfo.itemLink, questStatus))
  end
end

local lineAdded = false

local function OnIllusionBookTooltipAddLine(tooltip, ...)
   if not lineAdded then
      local _, link = tooltip:GetItem()
      if not link then return end
      local itemId = tonumber(string.match(link, 'item:(%d+):'))
      local questId = TomeOfIllusionsCheck.tomesToQuests[itemId]
      if questId then
         if IsQuestFlaggedCompleted(questId) then
            tooltip:AddLine(format("Already learned this tome", itemId))
            lineAdded = true
         else
            tooltip:AddLine(format("Have not learned this tome", itemId))
            lineAdded = true
         end
      end
   end
end

local function OnIllusionBookTooltipCleared(tooltip, ...)
   lineAdded = false
end

GameTooltip:HookScript("OnTooltipSetItem", OnIllusionBookTooltipAddLine)
GameTooltip:HookScript("OnTooltipCleared", OnIllusionBookTooltipCleared)
