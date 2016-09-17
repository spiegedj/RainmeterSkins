function Initialize()

  -- Public Variables
	measureTwitchFollows = SKIN:GetMeasure('MeasureTwitchFollows')
  __currentlyLoaded = 0
  __streams={}
  
  -- Constants
  MEASURE_COUNT=9
  WIDTH=SKIN:GetVariable('width', 300)
  
  -- Set the groupName
  for index=0,MEASURE_COUNT do
    groupName=StreamGroup(index)
    
    SKIN:Bang('!SetOption',MeterBackground(index),'Group',groupName)
    SKIN:Bang('!SetOption',MeterStreamTitle(index),'Group',groupName)
    SKIN:Bang('!SetOption',MeterStreamGame(index),'Group',groupName)
    SKIN:Bang('!SetOption',MeterStreamViewers(index),'Group',groupName)
    SKIN:Bang('!SetOption',MeterStreamImage(index),'Group',groupName)
  end
end

function Update()
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
  
  __currentlyLoaded=math.min(MEASURE_COUNT+1,#__streams)
  local index=0
  for key, stream in pairs(__streams) do
    if __currentlyLoaded<=index then break end
    PrintStream(index,stream["displayName"],stream["game"],stream["viewers"],stream["imageURL"],stream["link"],stream["status"])
    index=index+1
  end
  
  PrintLastUpdated()
end

function ParseFollows()
	local raw = measureTwitchFollows:GetStringValue()
	if raw == '' then
		return false
	end
	
	local matchStreams = '"streams":%[(.-)%],'
	local matchStream = '{"_id":(.-)}}'
	
	local matchGame = '"game":"(.-)",'
	local matchViewers = '"viewers":(.-),'
	
	--matchChannel = '"channel":{(.-)}'
	local matchStatus = '"status":"(.-)",'
	local matchDisplayName = '"display_name":"(.-)",'
	local matchLogo = '"logo":"(.-)",'
	
  HideAllStreams()
  
	local text = ''
	local rawStreams = raw:match(matchStreams)
	local index=0
	for rawStream in rawStreams:gmatch(matchStream) do
		game = rawStream:match(matchGame) or nil
		viewers = rawStream:match(matchViewers) or nil
		status = rawStream:match(matchStatus) or nil
		displayName = rawStream:match(matchDisplayName) or nil
		imageURL = rawStream:match(matchLogo) or nil
		link="http://www.twitch.tv/"..displayName
		
		PrintStream(index,displayName,game,viewers,imageURL,link,status)
		index = index + 1
	end
  __currentlyLoaded = index
  
  PrintLastUpdated()
end

function PrintLastUpdated()
  local timeString = os.date("%I:%M %p")
  SetTitle('MeterLastUpdated','Last Updated at '..timeString)
  SetPosition('MeterLastUpdated',WIDTH,30+(__currentlyLoaded * 60))
end

function HideAllStreams(index)
  for index=0,MEASURE_COUNT do
    groupName='StreamGroup'..index
    SKIN:Bang('!HideMeterGroup',groupName)
  end
end

function PrintStream(index,title,game,viewers,imageURL,link,status)
	width = WIDTH
	height = 60
	startX = 50
	startY = 30 + (index * height)
	
  -- Show Group
  SKIN:Bang('!ShowMeterGroup',StreamGroup(index))
  
	-- Background
	SetPosition(MeterBackground(index),0,startY-3)
	SetSize(MeterBackground(index),width,height-2)
  SetLeftMouseUpAction(MeterBackground(index), link)

	-- Stream Title
	SetTitle(MeterStreamTitle(index),title)
	SetPosition(MeterStreamTitle(index),startX,startY)
  
	-- Stream Game
	SetTitle(MeterStreamGame(index),'Playing '..game)
	SetPosition(MeterStreamGame(index),startX,startY+18)
	
	-- Stream Viewers
	SetTitle(MeterStreamViewers(index),viewers..' viewers')
	SetPosition(MeterStreamViewers(index),startX,startY+(18*2))
	
	-- Stream Image
	SetMeasureURL(MeasureStreamImage(index),imageURL)
	SetPosition(MeterStreamImage(index),5,startY+5)
	SetSize(MeterStreamImage(index),40,40)
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