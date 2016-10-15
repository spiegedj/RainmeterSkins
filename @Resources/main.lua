function Initialize()

  -- Public Variables
	measureTwitchFollows = SKIN:GetMeasure('MeasureTwitchFollows')
	measureYoutubeSubscriptions = SKIN:GetMeasure('MeasureYoutubScubscriptions')
  __currentlyLoaded = 0
  __streams={}
  __expandedIndex=-1
  __skinHeight=30
  
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
	for rawStream in raw:gmatch(matchStream) do
    local stream = {}
		stream["game"] = rawStream:match(matchGame) or ""
		stream["viewers"] = rawStream:match(matchViewers) or ""
		stream["status"] = rawStream:match(matchStatus) or ""
		stream["displayName"] = rawStream:match(matchDisplayName) or ""
		stream["imageURL"] = rawStream:match(matchLogo) or ""
		stream["link"] = "http://www.twitch.tv/"..stream["displayName"] or ""
		
    table.insert(__streams, stream)
	end
  
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
    
    table.insert(__streams, streamObj)
	end
  
  PrintStreams(true)
end

function PrintStreams(reloadImages)
  __currentlyLoaded = math.min(MEASURE_COUNT+1,#__streams)
  __skinHeight=30
  local index=0
  for key, stream in pairs(__streams) do
    if __currentlyLoaded<=index then break end
    PrintStream(index,stream,reloadImages)
    index=index+1
  end
  
  PrintLastUpdated()
end

function PrintLastUpdated()
  local timeString = os.date("%I:%M %p")
  SetTitle('MeterLastUpdated','Last Updated at '..timeString)
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
    elseif string.match(status, "terran") then table.insert(tags, "Terran") end
    
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

function JSONParse(str, pos, end_delim)
  pos = pos or 1
  if pos > #str then error('Reached unexpected end of input.') end
  local pos = pos + #str:match('^%s*', pos)  -- Skip whitespace.
  local first = str:sub(pos, pos)
  if first == '{' then  -- Parse an object.
    local obj, key, delim_found = {}, true, true
    pos = pos + 1
    while true do
      key, pos = JSONParse(str, pos, '}')
      if key == nil then return obj, pos end
      if not delim_found then error('Comma missing between object items.') end
      pos = skip_delim(str, pos, ':', true)  -- true -> error if missing.
      obj[key], pos = JSONParse(str, pos)
      pos, delim_found = skip_delim(str, pos, ',')
    end
  elseif first == '[' then  -- Parse an array.
    local arr, val, delim_found = {}, true, true
    pos = pos + 1
    while true do
      val, pos = JSONParse(str, pos, ']')
      if val == nil then return arr, pos end
      if not delim_found then error('Comma missing between array items.') end
      arr[#arr + 1] = val
      pos, delim_found = skip_delim(str, pos, ',')
    end
  elseif first == '"' then  -- Parse a string.
    return parse_str_val(str, pos + 1)
  elseif first == '-' or first:match('%d') then  -- Parse a number.
    return parse_num_val(str, pos)
  elseif first == end_delim then  -- End of an object or array.
    return nil, pos + 1
  else  -- Parse true, false, or null.
    local literals = {['true'] = true, ['false'] = false, ['null'] = {}}
    for lit_str, lit_val in pairs(literals) do
      local lit_end = pos + #lit_str - 1
      if str:sub(pos, lit_end) == lit_str then return lit_val, lit_end + 1 end
    end
    local pos_info_str = 'position ' .. pos .. ': ' .. str:sub(pos, pos + 10)
    error('Invalid json syntax starting at ' .. pos_info_str)
  end
end

function kind_of(obj)
  if type(obj) ~= 'table' then return type(obj) end
  local i = 1
  for _ in pairs(obj) do
    if obj[i] ~= nil then i = i + 1 else return 'table' end
  end
  if i == 1 then return 'table' else return 'array' end
end

function escape_str(s)
  local in_char  = {'\\', '"', '/', '\b', '\f', '\n', '\r', '\t'}
  local out_char = {'\\', '"', '/',  'b',  'f',  'n',  'r',  't'}
  for i, c in ipairs(in_char) do
    s = s:gsub(c, '\\' .. out_char[i])
  end
  return s
end

function skip_delim(str, pos, delim, err_if_missing)
  pos = pos + #str:match('^%s*', pos)
  if str:sub(pos, pos) ~= delim then
    if err_if_missing then
      error('Expected ' .. delim .. ' near position ' .. pos)
    end
    return pos, false
  end
  return pos + 1, true
end

function parse_str_val(str, pos, val)
  val = val or ''
  local early_end_error = 'End of input found while parsing string.'
  if pos > #str then error(early_end_error) end
  local c = str:sub(pos, pos)
  if c == '"'  then return val, pos + 1 end
  if c ~= '\\' then return parse_str_val(str, pos + 1, val .. c) end
  -- We must have a \ character.
  local esc_map = {b = '\b', f = '\f', n = '\n', r = '\r', t = '\t'}
  local nextc = str:sub(pos + 1, pos + 1)
  if not nextc then error(early_end_error) end
  return parse_str_val(str, pos + 2, val .. (esc_map[nextc] or nextc))
end

function parse_num_val(str, pos)
  local num_str = str:match('^-?%d+%.?%d*[eE]?[+-]?%d*', pos)
  local val = tonumber(num_str)
  if not val then error('Error parsing number at position ' .. pos .. '.') end
  return val, pos + #num_str
end