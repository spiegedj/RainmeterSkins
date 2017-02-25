function Initialize()

  -- Imports
  dofile(SKIN:GetVariable('@')..'Scripts\\JSONParser.lua')
  dofile(SKIN:GetVariable('@')..'Scripts\\Utils.lua')
  dofile(SKIN:GetVariable('@')..'Scripts\\StreamsBase.lua')

  -- Public Variables
	measureTwitchParser = SKIN:GetMeasure('MeasureTwitchParser')
	measureYoutubeSubscriptions = SKIN:GetMeasure('MeasureYoutubScubscriptions')

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

function ParseFriends()
  measureSteamFriends = SKIN:GetMeasure('MeasureSteamFriends')
	local raw = measureSteamFriends:GetStringValue()
	if raw == '' then
		return false
	end

  raw = string.gsub(raw, ">%s-<", "><")

  local matchFriend = '<div class="friendBlock(.-)</div></div>'

	local matchIDURL= '<a class="friendBlockLinkOverlay" href="(.-)"></a>'
  local matchID = 'steamid":"(.-)","'
  local matchImage = '<img src="(.-)">'
  local matchName= '<div class="friendBlockContent">(.-)<br>'
  local matchStatus= '<span class="friendSmallText">(.-)</span>'
  local matchOnline = '<span class="linkFriend_in%-game">(.-)</span>'

  __streams={}
  index=1
  for rawFriend in raw:gmatch(matchFriend) do
    local streamObj = {}
    local name = rawFriend:match(matchName)
    local status = rawFriend:match(matchStatus)
    local image = rawFriend:match(matchImage)
    local online = rawFriend:match(matchOnline)

    local game = ""
    if online then
      status = online:match('(.*)<br/>')
      game = online:match('<br/>(.*)')
      streamObj["statusColor"] = '144,186,60'
    elseif trim(status) == 'Online' then
      streamObj["statusColor"] = '87,203,222'
    else 
      streamObj["statusColor"] = '102,102,102'
    end

    streamObj["status"]=""
    streamObj["game"]=cleanString(status)
    streamObj["viewers"]=cleanString(game)
    streamObj["displayName"]=cleanString(name)
    streamObj["imageURL"]=cleanString(image)
    streamObj["link"]=""
    
    __streams[index-1] = streamObj
    index=index+1
  end

  PrintStreams(true)
end

function ParseFeatured()
	local raw = measureTwitchParser:GetStringValue()
	if raw == '' then
		return false
	end
	
	local matchStream = '"stream":{"_id":(.-)}}'
	local matchGame = '"game":"(.-)",'
	local matchViewers = '"viewers":(.-),'
	
	--matchChannel = '"channel":{(.-)}'
	local matchStatus = '"status":"(.-)",'
	local matchDisplayName = '"display_name":"(.-)",'
	local matchLogo = '"logo":"(.-)",'
	
  HideAllStreams()
  
	local text = ''

  __streams={}
  local i = 0
	for rawStream in raw:gmatch(matchStream) do
    local stream = {}
		stream["game"] = rawStream:match(matchGame) or ""
		stream["viewers"] = rawStream:match(matchViewers) or ""
		stream["status"] = rawStream:match(matchStatus) or ""
		stream["displayName"] = rawStream:match(matchDisplayName) or ""
		stream["imageURL"] = rawStream:match(matchLogo) or ""
		stream["link"] = "http://www.twitch.tv/"..stream["displayName"] or ""
		
    __streams[index-1] = streamObj
	end
  
    __timestamp = os.date("%I:%M %p")
  PrintStreams(true)
end

function ParseStreams()
	local raw = measureTwitchParser:GetStringValue()
	if raw == '' then
		return false
	end
	
  local responseDictionary = JSONParse(raw)
	
  HideAllStreams()
  __streams={}
	for index,stream in pairs(responseDictionary["streams"]) do
    local streamObj = {}
    local channel = stream["channel"]
    streamObj["status"]=channel["status"] or ""
    streamObj["game"]='Playing ' .. (channel["game"] or "")
    streamObj["viewers"]=(stream["viewers"] or "") .. ' viewers'
    streamObj["displayName"]=channel["display_name"] or ""
    streamObj["imageURL"]=channel["logo"] or ""
    streamObj["link"]="http://www.twitch.tv/"..streamObj["displayName"] or ""
    
    __streams[index-1] = streamObj

	end
  
  __timestamp = os.date("%I:%M %p")
  PrintStreams(true)
end

function PrintStreams(reloadImages)
  HideAllStreams()

  local startIndex = (__pageNumber*MEASURE_COUNT)
  local endIndex = startIndex + MEASURE_COUNT - 1
  endIndex = math.min(#__streams, endIndex)

  __skinHeight=30
  local measureIndex=0
  for i = startIndex,endIndex do
    local stream = __streams[i]
    PrintStream(measureIndex,stream,reloadImages)
    measureIndex=measureIndex+1
  end
  
  PrintNavigation()
  --PrintLastUpdated()
end

function Refresh()
  HideAllStreams()
	SKIN:Bang("!CommandMeasure", "MeasureTwitchParser", "Update");
end

function PrintLastUpdated()
  SetTitle('MeterLastUpdated','Last Updated at '..__timestamp)
  SetPosition('MeterLastUpdated',WIDTH,__skinHeight)
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

function ExpandRow(index)
   if __expandedIndex == index then
    __expandedIndex=-1
   else 
    __expandedIndex=index
   end   

   PrintStreams(false)
end

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