local addonName, _ = ...

TomeOfIllusionsCheck = {
  name = addonName,
  version = GetAddOnMetadata(addonName, "Version"),
  author = GetAddOnMetadata(addonName, "Author"),
}

local tomesToQuests = {
   [138795] = 42879, -- Tome of Illusions: Draenor
   [138793] = 42877, -- Tome of Illusions: Pandaria
   [138794] = 42878, -- Tome of Illusions: Secrets of the Shado-pan
   [138791] = 42875, -- Tome of Illusions: Cataclysm
   [138792] = 42876, -- Tome of Illusions: Elemental Lords
   [138790] = 42874, -- Tome of Illusions: Northrend
   [138789] = 42873, -- Tome of Illusions: Outland
   [138787] = 42871, -- Tome of Illusions: Azeroth
}

local lineAdded = false

local function OnIllusionBookTooltipAddLine(tooltip, ...)
   if not lineAdded then
      local name, link = tooltip:GetItem()
      local itemId = tonumber(string.match(link, 'item:(%d+):'))
      local questId = tomesToQuests[itemId]
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
