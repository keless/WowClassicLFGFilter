-- NOTE: to turn on lua errors:
-- /console scriptErrors 1   

-- utility code

function StringContainsWholeWord(haystack, needle)
    return string.find(haystack, "%f[%a]" .. needle .. "%f[%A]")
end

function ArrayContains(array, item)
    for key, value in pairs(array) do
        if value == item then 
            return key 
        end
    end
    return false
end

-- return true if any items in 'array' are substrings inside of 'string'
function StringMatchesAnyInArray(string, array)
    for index, value in ipairs(array) do
        if string:match(value) then
            return true
        end
    end

    return false
end

-- set up LFG chat tab
function SetUpLFGChatTab()
    local chatFrame = GetLFGChatTab()
    ChatFrame_AddChannel(chatFrame, "LookingForGroup")
    ChatFrame_AddChannel(chatFrame, "System Messages") -- for 'who' results
    ChatFrame_AddChannel(chatFrame, "Whisper")
    --ChatFrame_AddChannel(chatFrame, ChatTypeInfo["WHISPER"])

    FCF_SelectDockFrame(chatFrame)
end

function GetSelectedChatTab()
    return FCFDock_GetSelectedWindow(GENERAL_CHAT_DOCK)
end

-- get chat tab for LFG
function GetLFGChatTab()
    local foundLFG = nil

    for _,chatName in ipairs(CHAT_FRAMES) do
      local chatFrame = _G[chatName]
      if chatFrame.name == "LFG" or chatFrame.name == "LookingForGroup" then
        foundLFG = chatFrame
      end
    end

    if not foundLFG then
        print("Error: could not find LFG chat tab")
        return nil
    end

    return foundLFG
end

function PrintLFGTab(msg, r, g, b, messageGroup)
    local tab = GetLFGChatTab()
    if not tab then return end

    tab:AddMessage(msg, r, g, b, messageGroup)
end


function PrintCurrentTab(msg)
    local currentTab = GetSelectedChatTab()
        if not tab then return end

    tab:AddMessage(msg, 1, 1, 1)
end

-- filter functions
local dungeonKeywords = {}
dungeonKeywords["rfc"] = {"ragefire", "rfc"}
dungeonKeywords["dm"] = {"deadmines", "dm", "vc"}
dungeonKeywords["wc"] = {"wailing", "wc"}
dungeonKeywords["sfk"] = {"shadowfang", "sfk"}
dungeonKeywords["bfd"] = {"blackfathom", "bfd"}
dungeonKeywords["stock"] = {"stock", "sc"}
dungeonKeywords["gnome"] = {"gnome", "gn", "gmr"}
dungeonKeywords["rfk"] = {"kraul", "rfk"}
dungeonKeywords["sm"] = {"scarlet", "sm", "cath", "gy", "lib", "arm"}
dungeonKeywords["rfd"] = {"downs", "rfd"}
dungeonKeywords["ulda"] = {"uld"}
dungeonKeywords["zf"] = {"zulf", "zul'farrak", "zf"}
dungeonKeywords["mara"] = {"mara"}
dungeonKeywords["st"] = {"st", "temple of atal'hakkar", "sunken"}
dungeonKeywords["brd"] = {"brd", "blackrock", "depths"}
dungeonKeywords["lbrs"] = {"lbrs", "lower"}
dungeonKeywords["ubrs"] = {"ubrs", "upper"}
dungeonKeywords["maul"] = {"dire", "maul", "east", "west", "north"}
dungeonKeywords["strath"] = {"strath", "live", "dead"}
dungeonKeywords["scholo"] = {"scholo"}
-- todo:
--onyx
--zg
--mc
--bwl
--aq
--nax

local CURRENT_FILTER_KEY = nil

function FilterFunction(chatFrame, event, msg)
    if not (chatFrame.name == "LFG" or chatFrame.name == "LookingForGroup") then return false end
    local filterArray = dungeonKeywords[CURRENT_FILTER_KEY]
    msg = msg:lower()
    --print("do filter on " .. CURRENT_FILTER_KEY .. " : " .. msg)
    local isMatch = StringMatchesAnyInArray(msg, filterArray)
    --if isMatch then
    --    --todo: only print to the LFG channel
    --    print(date("%H:%M:%S - " .. msg ))
    --end
    return not isMatch
end

function SetFilter(filterName)
    ClearFilter()

    local filterArray = dungeonKeywords[filterName]
    if (filterArray) then
        CURRENT_FILTER_KEY = filterName
        ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", FilterFunction)
        PrintCurrentTab("lfg - now filtering on " .. CURRENT_FILTER_KEY)
    end
end

function ClearFilter()
    CURRENT_FILTER_KEY = nil
    ChatFrame_RemoveMessageEventFilter("CHAT_MSG_CHANNEL", FilterFunction)
end


-- slash command
SLASH_LFG1 = "/lfg"
SlashCmdList["LFG"] = function(msg, editbox)
  local _, _, cmd, args = string.find(msg, "%s?(%w+)%s?(.*)")

  if dungeonKeywords[cmd] then
    SetUpLFGChatTab()
    SetFilter(cmd)
  elseif cmd == "none" or cmd == "clear" then
    ClearFilter()
    PrintCurrentTab("lfg - stopped filtering")
  elseif cmd == "test" then
    SetUpLFGChatTab()
  elseif cmd == "list" then
    PrintCurrentTab ("none - disable filter")
    PrintCurrentTab ("rfc - ragefire chasm [10-18:min 8]<orgrimar>")
    PrintCurrentTab ("dm - deadmines [17-24:min 10]<westfall>")
    PrintCurrentTab ("wc - wailing caverns [17-24:min 10]<barrens>")
    PrintCurrentTab ("sfk - shadowfang keep [22-30:min 10]<silverpine forest>")
    PrintCurrentTab("bfd - blackfathom deeps")
    PrintCurrentTab("stock - stockades")
    PrintCurrentTab("gnome - gnomergan")
    PrintCurrentTab("rfk - razorfen kraul")
    PrintCurrentTab("sm - scarlet monastery")
    PrintCurrentTab("rfd - razorfen downs")
    PrintCurrentTab("ulda - uldaman")
    PrintCurrentTab("zf - zul'farrak")
    PrintCurrentTab("mara - maradaun")
    PrintCurrentTab("st - sunken temple")
    PrintCurrentTab("brd - blackrock depths")
    PrintCurrentTab("lbrs - lower blackrock spire")
    PrintCurrentTab("ubrs - upper blackrock spire")
    PrintCurrentTab("strath - stratholme")
    PrintCurrentTab("scholo - scholomance")
  else
    if (CURRENT_FILTER_KEY) then
      PrintCurrentTab("lfg - currently filtering for " .. CURRENT_FILTER_KEY)
    end
    PrintCurrentTab("lfg [instance name] - set filter to instance")
    PrintCurrentTab("lfg list - lists instance names recognized by this script")
  end
end