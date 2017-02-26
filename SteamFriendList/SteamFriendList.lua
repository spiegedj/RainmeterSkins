function Initialize()
    -- Imports
    dofile(SKIN:GetVariable('@')..'Scripts\\JSONParser.lua')
    dofile(SKIN:GetVariable('@')..'Scripts\\Utils.lua')
    dofile(SKIN:GetVariable('@')..'Scripts\\ListManager.lua')

    -- Globals
    __Friends = {}
    __PlayerSummaries = {}
    __MeasureGetPlayerSummaries = SKIN:GetMeasure('MeasureGetPlayerSummaries')
    __ListManager = ListManager:new(nil)

    -- Enums
    __StateCodes = {"Online","Busy","Away", "Snooze", "Looking to Play", "In Game"}
    __StateCodes[0] = "Offline"
    
end

function GetFriends()
    local measure = SKIN:GetMeasure('MeasureGetSteamFriends')
    local raw = measure:GetStringValue()
    __Friends = JSONParse(raw)
    local friendIdString = CreateFriendIdString(__Friends)
    GetPlayerSummaries(friendIdString)
end

function CreateFriendIdString(friendDictionary)
  local friendIdString = ",76561198002070552"
	for index,friendObj in pairs(friendDictionary["friendslist"]["friends"]) do
    friendIdString = friendObj["steamid"] .. "," .. friendIdString
	end
  return friendIdString
end

function GetPlayerSummaries(friendIdString)
    local playerSummaryURL = "http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=0CBFF8ED6037C926E8194B72676DBD04&steamids="
    playerSummaryURL = playerSummaryURL .. friendIdString
    SetMeasureURL('MeasureGetPlayerSummaries', playerSummaryURL)
end

function LoadPlayerSummaries()
    local raw = __MeasureGetPlayerSummaries:GetStringValue()
    local playerSummaryResponse = JSONParse(raw)["response"]["players"]

    __PlayerSummaries = {}
    for i, playerObj in pairs(playerSummaryResponse) do
        __PlayerSummaries[i] = ConstructPlayerSummary(playerObj)
    end

    SortPlayerSummaries(__PlayerSummaries)

    __ListManager.List = __PlayerSummaries
    __ListManager:Print(true)
end

function ConstructPlayerSummary(playerObj)
    local playerSummary = {}
    local name = playerObj["personaname"]
    local state = playerObj["personastate"]
    local image = playerObj["avatarmedium"]
    local game = playerObj["gameextrainfo"]

    -- Offline
    playerSummary["statusColor"] = '102,102,102'

    -- If Online
    if state > 0 then
        playerSummary["statusColor"] = '87,203,222'
    end

    -- If In Game
    if game then
        state = 6
        playerSummary["statusColor"] = '144,186,60'
    end

    playerSummary["stateCode"] = state

    playerSummary["title"]=cleanString(name)
    playerSummary["line1"]=__StateCodes[state]
    playerSummary["line2"]=cleanString(game)
    playerSummary["imageURL"]=cleanString(image)
    playerSummary["link"]=""

    return playerSummary
end

function SortPlayerSummaries(playerSummaries)
    table.sort(playerSummaries, function (a, b)
        -- flip online and in game state codes
        local compareValueA = a["stateCode"]
        if a["stateCode"] == 0 then compareValueA = 6 end
        if a["stateCode"] == 6 then compareValueA = 0 end

        local compareValueB = b["stateCode"]
        if b["stateCode"] == 0 then compareValueB = 6 end
        if b["stateCode"] == 6 then compareValueB = 0 end

        return compareValueA < compareValueB
    end)
end

-- Navigation

function NextPage()
    __ListManager:NextPage()
end

function PreviousPage()
    __ListManager:PreviousPage()
end