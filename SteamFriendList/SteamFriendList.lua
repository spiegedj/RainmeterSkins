function Initialize()
    -- Imports
    dofile(SKIN:GetVariable('@')..'Scripts\\JSONParser.lua')
    dofile(SKIN:GetVariable('@')..'Scripts\\Utils.lua')
    dofile(SKIN:GetVariable('@')..'Scripts\\StreamsBase.lua')

    -- Globals
    __Friends = {}
    __PlayerSummaries = {}
    __MeasureGetPlayerSummaries = SKIN:GetMeasure('MeasureGetPlayerSummaries')

    -- Enums
    __StateCodes = {"Online","Busy","Away", "Snooze", "Looking to Play", "In Game"}
    __StateCodes[0] = "Offline"


    __streams={}
    __expandedIndex=-1
    __skinHeight=30
    __pageNumber=0
    __timestamp=""

    -- Constants
    MAX_COUNT=10
    MEASURE_COUNT = SKIN:GetVariable('measureCount', MAX_COUNT)
    WIDTH=SKIN:GetVariable('width', 300)

    -- Set the groupName
    for index=0,MAX_COUNT do
        groupName=StreamGroup(index)

        SKIN:Bang('!SetOption',MeterBackground(index),'Group',groupName)
        SKIN:Bang('!SetOption',MeterStreamTitle(index),'Group',groupName)
        SKIN:Bang('!SetOption',MeterStreamGame(index),'Group',groupName)
        SKIN:Bang('!SetOption',MeterStreamViewers(index),'Group',groupName)
        SKIN:Bang('!SetOption',MeterStreamImage(index),'Group',groupName)
        SKIN:Bang('!SetOption',MeterStreamDivider(index),'Group',groupName)
        SKIN:Bang('!SetOption',MeterStreamChevronDown(index),'Group',groupName)
        SKIN:Bang('!SetOption',MeterStreamChevronUp(index),'Group',groupName)
        SKIN:Bang('!SetOption',MeterStreamSidebar(index),'Group',groupName)
        SKIN:Bang('!SetOption',MeterStreamDetails(index),'Group',groupName)

        Hide(MeterStreamChevronUp(index))
        Hide(MeterStreamChevronDown(index))
    end
end

function GetFriends()
    local measure = SKIN:GetMeasure('MeasureGetSteamFriends')
    local raw = measure:GetStringValue()
    __Friends = JSONParse(raw)
    local friendIdString = CreateFriendIdString(__Friends)
    GetPlayerSummaries(friendIdString)
end

function CreateFriendIdString(friendDictionary)
    local friendIdString = ""
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

    __streams = __PlayerSummaries
    PrintStreams(true)
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

    playerSummary["status"]=""
    playerSummary["game"]=__StateCodes[state]
    playerSummary["viewers"]=cleanString(game)
    playerSummary["displayName"]=cleanString(name)
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

-- Printing

function PrintStreams(reloadImages)
  HideAllStreams()

  local startIndex = (__pageNumber*MEASURE_COUNT)
  local endIndex = startIndex + MEASURE_COUNT - 1
  endIndex = math.min(#__streams, endIndex)

  __skinHeight=30
  local measureIndex=0
  for i = startIndex,endIndex do
    local stream = __streams[i + 1]
    PrintStream(measureIndex,stream,reloadImages)
    measureIndex=measureIndex+1
  end
  
  PrintNavigation()
end


function HideAllStreams()
  for index=0,MEASURE_COUNT do
    groupName='StreamGroup'..index
    SKIN:Bang('!HideMeterGroup',groupName)
  end
end

function PrintStream(index,stream,reloadImage)
  local title=stream["displayName"]
  local game=stream["game"]
  local viewers=stream["viewers"]
  local imageURL=stream["imageURL"]
  local link=stream["link"]
  local status=stream["status"]
  local statusColor=stream["statusColor"]

  local expanded = (__expandedIndex == index)

	width = WIDTH
  sidebarWidth = 30
  if not expanded then
    height = 60
  else
    height = 120
  end

	startX = 50
  startY = __skinHeight
  __skinHeight = __skinHeight + height
  
  -- Show Group
  SKIN:Bang('!ShowMeterGroup',StreamGroup(index))
  
	-- Background
	SetPosition(MeterBackground(index),0,startY-3)
	SetSize(MeterBackground(index),width-sidebarWidth,height-2)
  SetLeftMouseUpAction(MeterBackground(index), link)

	-- Stream Title
	SetTitle(MeterStreamTitle(index),title)
	SetPosition(MeterStreamTitle(index),startX,startY)
  SetFontColor(MeterStreamTitle(index), statusColor)

  
	-- Stream Game
  local tags = FindTags(status, game)
  SetTitle(MeterStreamGame(index),game..tags)
  SetPosition(MeterStreamGame(index),startX,startY+18)
  SetFontColor(MeterStreamGame(index), statusColor)
	
	-- Stream Viewers
	SetTitle(MeterStreamViewers(index),viewers)
	SetPosition(MeterStreamViewers(index),startX,startY+(18*2))
  SetFontColor(MeterStreamViewers(index), statusColor)
	
	-- Stream Image
  if reloadImage then
    SetMeasureURL(MeasureStreamImage(index),imageURL)
  end
  SetPosition(MeterStreamImage(index),5,startY+5)
  SetSize(MeterStreamImage(index),40,40)
  
  -- Stream Sidebar
  SetPosition(MeterStreamSidebar(index),WIDTH-sidebarWidth,startY-3)
	SetSize(MeterStreamSidebar(index),sidebarWidth,height)
  
  -- Stream Chevrons
  Hide(MeterStreamChevronUp(index))
  Hide(MeterStreamChevronDown(index))
  if not expanded then
    Show(MeterStreamChevronDown(index))
    SetPosition(MeterStreamChevronDown(index),width-20,startY+40)
    SetSize(MeterStreamChevronDown(index),12,10)
  else 
    Show(MeterStreamChevronUp(index))
    SetPosition(MeterStreamChevronUp(index),width-20,startY+40)
    SetSize(MeterStreamChevronUp(index),12,10)
  end
  
  -- Stream Details
  if expanded then
    SetTitle(MeterStreamDetails(index),status)
    SetPosition(MeterStreamDetails(index),5,startY+60)
    SetSize(MeterStreamDetails(index),WIDTH-sidebarWidth,60)
  else 
    SetTitle(MeterStreamDetails(index),"")
    SetSize(MeterStreamDetails(index),0,0)
  end
  
  -- Stream Divider
	SetPosition(MeterStreamDivider(index),0,startY+height-4)
  SetSize(MeterStreamDivider(index),WIDTH,1)
end

function FindTags(status, game)
  local status = string.lower(status)
  local tags = {}
  
    -- ALL
  if string.match(status, "rerun") then table.insert(tags, "RERUN") end
  
  -- StarCraft II
  if game == "StarCraft II" then
    if string.match(status, "protoss") then table.insert(tags, "Protoss")
    elseif string.match(status, "zerg") then table.insert(tags, "Zerg")
    elseif string.match(status, "terran") then table.insert(tags, "Terran")
    elseif string.match(status, "random") then table.insert(tags, "Random") end
    
    if string.match(status, "pvp") then table.insert(tags, "PvP")
    elseif string.match(status, "pvt") then table.insert(tags, "PvT")
    elseif string.match(status, "pvz") then table.insert(tags, "PvZ")
    elseif string.match(status, "tvz") then table.insert(tags, "TvZ")
    elseif string.match(status, "tvt") then table.insert(tags, "TvT")
    elseif string.match(status, "zvz") then table.insert(tags, "ZvZ") end
  end
  
  if #tags == 0 then return "" end
  
  return " - "..table.concat(tags, ", ")
end

-- Navigation

function PrintNavigation()
  SetSize('MeterNavPrevious', 12, 12)
  SetSize('MeterNavNext', 12, 12)
  SetPosition('MeterNavPrevious',16,6)
  SetPosition('MeterNavNext',32,6)

  Hide('MeterNavPrevious')
  Hide('MeterNavNext')
  if __pageNumber > 0 then
    Show('MeterNavPrevious')
  end

  local maxPageCount = math.ceil(#__streams / MEASURE_COUNT)
  if __pageNumber < (maxPageCount - 1) then
    Show('MeterNavNext')
  end
end

function NextPage()
  __pageNumber = __pageNumber + 1
  PrintStreams(true)
end

function PreviousPage()
  __pageNumber = math.max(__pageNumber - 1, 0)
    PrintStreams(true)
end