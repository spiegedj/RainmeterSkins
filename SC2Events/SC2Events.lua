function Initialize()
    -- Imports
    dofile(SKIN:GetVariable('@')..'Scripts\\JSONParser.lua')
    dofile(SKIN:GetVariable('@')..'Scripts\\Utils.lua')
    dofile(SKIN:GetVariable('@')..'Scripts\\StreamsBase.lua')

    -- Globals
    __Events = {}
    __PlayerSummaries = {}
    __MeasureGetPlayerSummaries = SKIN:GetMeasure('MeasureGetPlayerSummaries')

    -- Enums
    __expandedIndex=-1
    __skinHeight=30
    __pageNumber=0
    __timestamp=""

    -- Constants
    MAX_COUNT=5
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

function GetEvents()
    local measure = SKIN:GetMeasure('MeasureGetSC2Events')
    local raw = measure:GetStringValue()
    local response = JSONParse(raw)
    
    __Events = {}
    for i, event in pairs(response["events"]) do
        __Events[i] = ConstructEvent(event)
    end

    SortEvents(__Events)

    __streams = __Events
    PrintStreams(true)
end

function Refresh()
    for i, event in pairs(__Events) do
        event["game"] = GetCountdownString(event["timeMS"])
    end

    PrintStreams(false)
end

function ConstructEvent(event)
    local eventSummary = {}
    local name = event["name"]
    local details = event["details"]
    local timeMS = event["time"]
    local image = event["image"]

    local date = os.date("%B %d - %A @ %I:%M %p", timeMS/1000)
    local daysFrom = os.difftime(timeMS/1000, os.time()) / (24 * 60 * 60)
    local countdown = GetCountdownString(timeMS)

    eventSummary["statusColor"] = '200,200,200'
    if daysFrom < 3 then
        eventSummary["statusColor"] = '87,203,222'
        if daysFrom < 1 then
            eventSummary["statusColor"] = '144,186,60'
        end
    end

    eventSummary["status"]=""
    eventSummary["tags"]=cleanString(details)
    eventSummary["game"]=cleanString(countdown)
    eventSummary["viewers"]=cleanString(date)
    eventSummary["displayName"]=cleanString(name)..": "..cleanString(details)
    eventSummary["imageURL"]=cleanString(image)
    eventSummary["link"]=""

    eventSummary["timeMS"]=timeMS

    return eventSummary
end

function GetCountdownString(timeMS)
    local daysFrom = os.difftime(timeMS/1000, os.time()) / (24 * 60 * 60)
    local days = math.floor(daysFrom)
    local hoursFrom = (daysFrom - days) * 24
    local hours = math.floor(hoursFrom)
    local minutesFrom = (hoursFrom - hours) * 60
    local minutes = math.floor(minutesFrom)
    return "Live in " .. days .. "d " .. hours .. "h " .. minutes .. "m"
end

function SortEvents(events)
    table.sort(events, function (a, b)
        -- flip online and in game state codes
        local compareValueA = a["timeMS"]
        local compareValueB = b["timeMS"]
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

  startX = "60"
  startY = __skinHeight
  __skinHeight = __skinHeight + height
  
  -- Show Group
  SKIN:Bang('!ShowMeterGroup',StreamGroup(index))
  
	-- Background
	SetPosition(MeterBackground(index),0,startY-3)
    SetSize(MeterBackground(index),width,height-2)
  SetLeftMouseUpAction(MeterBackground(index), link)

	-- Stream Title
	SetTitle(MeterStreamTitle(index),title)
	SetPosition(MeterStreamTitle(index),startX,startY)
  SetFontColor(MeterStreamTitle(index), statusColor)

	-- Stream Game
  SetTitle(MeterStreamGame(index),game)
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
  SKIN:Bang('!SetOption',MeterStreamImage(index),'W',50)
  --SetSize(MeterStreamImage(index),40,40)
  
  -- Stream Sidebar
  SetPosition(MeterStreamSidebar(index),WIDTH-sidebarWidth,startY-3)
	SetSize(MeterStreamSidebar(index),sidebarWidth,height)
  
  -- Stream Chevrons
  Hide(MeterStreamChevronUp(index))
  Hide(MeterStreamChevronDown(index))
--   if not expanded then
--     Show(MeterStreamChevronDown(index))
--     SetPosition(MeterStreamChevronDown(index),width-20,startY+40)
--     SetSize(MeterStreamChevronDown(index),12,10)
--   else 
--     Show(MeterStreamChevronUp(index))
--     SetPosition(MeterStreamChevronUp(index),width-20,startY+40)
--     SetSize(MeterStreamChevronUp(index),12,10)
--   end
  
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