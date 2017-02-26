function Initialize()
  -- Imports
  dofile(SKIN:GetVariable('@')..'Scripts\\JSONParser.lua')
  dofile(SKIN:GetVariable('@')..'Scripts\\Utils.lua')
  dofile(SKIN:GetVariable('@')..'Scripts\\ListManager.lua')

  -- Public Variables
  measureTwitchParser = SKIN:GetMeasure('MeasureTwitchParser')

  __streams={}
  __ListManager = ListManager:new(nil)
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

  __streams = {}
  local i = 0
	for rawStream in raw:gmatch(matchStream) do
    local stream = {}
		stream["title"] = rawStream:match(matchDisplayName) or ""
		stream["line1"] = rawStream:match(matchGame) or ""
		stream["line2"] = rawStream:match(matchViewers) or ""
		stream["details"] = rawStream:match(matchStatus) or ""
		stream["imageURL"] = rawStream:match(matchLogo) or ""
		stream["link"] = "http://www.twitch.tv/"..stream["displayName"] or ""
		
    __streams[index-1] = streamObj
	end
  
  __timestamp = os.date("%I:%M %p")
  __ListManager.List = __streams
  __ListManager:Print(true)
end

function ParseStreams()
	local raw = measureTwitchParser:GetStringValue()
	if raw == '' then
		return false
	end
	
  local responseDictionary = JSONParse(raw)
	
  __streams={}
	for index,stream in pairs(responseDictionary["streams"]) do
    local streamObj = {}
    local channel = stream["channel"]
    local tags = FindTags(channel["status"], channel["game"])

    streamObj["title"] = channel["display_name"] .. tags
    streamObj["line1"] = 'Playing ' .. (channel["game"] or "")
    streamObj["line2"] = (stream["viewers"] or "") .. ' viewers'
    streamObj["details"] = channel["status"] or ""
    streamObj["imageURL"] = channel["logo"] or ""
    streamObj["link"] = "http://www.twitch.tv/" .. streamObj["title"] or ""
    

    __streams[index] = streamObj
	end
  
  __ListManager.List = __streams
  __ListManager:Print(true)
end

function Refresh()
  __ListManager:Refresh()
end

function ExpandRow(index)
  __ListManager:ExpandRow(index)
end

function NextPage()
  __ListManager:NextPage()
end

function PreviousPage()
  __ListManager:PreviousPage()
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