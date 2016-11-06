function Initialize()

  -- Imports
  dofile(SKIN:GetVariable('@')..'Scripts\\JSONParser.lua')

  -- Public Variables
	measureTwitchFollows = SKIN:GetMeasure('MeasureTwitchFollows')
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

function ParseFeatured()
	local raw = measureTwitchFollows:GetStringValue()
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
	local raw = measureTwitchFollows:GetStringValue()
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
    streamObj["game"]=channel["game"] or ""
    streamObj["viewers"]=stream["viewers"] or ""
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
  PrintLastUpdated()
end

function PrintLastUpdated()
  SetTitle('MeterLastUpdated','Last Updated at '..__timestamp)
  SetPosition('MeterLastUpdated',WIDTH,__skinHeight)
end

function HideAllStreams(index)
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
  
	-- Stream Game
  local tags = FindTags(status, game)
	SetTitle(MeterStreamGame(index),'Playing '..game..tags)
	SetPosition(MeterStreamGame(index),startX,startY+18)
	
	-- Stream Viewers
	SetTitle(MeterStreamViewers(index),viewers..' viewers')
	SetPosition(MeterStreamViewers(index),startX,startY+(18*2))
	
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
  SetPosition('MeterNavPrevious',16,__skinHeight)
  SetPosition('MeterNavNext',32,__skinHeight)

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

-- Stream Group
function StreamGroup(index)
  return 'StreamGroup'..index
end

-- Stream Background
function MeterBackground(index)
  return 'MeterBackground'..index
end

-- Stream Title
function MeterStreamTitle(index)
  return 'MeterStreamTitle'..index
end

-- Stream Game
function MeterStreamGame(index)
  return 'MeterStreamGame'..index
end

-- Stream Viewers
function MeterStreamViewers(index)
  return 'MeterStreamViewers'..index
end

-- Stream Image
function MeterStreamImage(index)
  return 'MeterImage'..index
end
function MeasureStreamImage(index)
  return 'MeasureImage'..index
end

-- Stream Sidebar
function MeterStreamSidebar(index)
  return 'MeterSidebar'..index
end

-- Stream Chevron Down
function MeterStreamChevronDown(index)
  return 'MeterChevronDown'..index
end

-- Stream Chevron Up
function MeterStreamChevronUp(index)
  return 'MeterChevronUp'..index
end

-- Stream Details
function MeterStreamDetails(index)
  return 'MeterDetails'..index
end

-- Stream Divider
function MeterStreamDivider(index)
  return 'MeterDivider'..index
end



function SetLeftMouseUpAction(meter, link)
	SKIN:Bang('!SetOption',meter,'LeftMouseUpAction',link)
end

function SetMeasureURL(measure,url)
	SKIN:Bang('!SetOption',measure,'URL',url)
	SKIN:Bang('!CommandMeasure',measure,'Update')
end

function SetPosition(meter,x,y)
	SKIN:Bang('!SetOption',meter,'X',x)
	SKIN:Bang('!SetOption',meter,'Y',y)
end

function SetTitle(meter,title)
	SKIN:Bang('!SetOption',meter,'Text',title)
end

function SetSize(meter,width,height)
	SKIN:Bang('!SetOption',meter,'W',width)
	SKIN:Bang('!SetOption',meter,'H',height)
end

function Hide(meter)
	SKIN:Bang('!HideMeter',meter)
end

function Show(meter)
	SKIN:Bang('!ShowMeter',meter)
end