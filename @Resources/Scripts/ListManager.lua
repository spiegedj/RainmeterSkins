ListManager = {
    List = {},
    __expandedIndex = -1,
    __skinHeight = 30,
    __pageNumber = 0,
    __timestamp = "",
    __maxCount = 5,
    __measureCount = 5,
    __width = 300,
    __timestamp = ""
}

function ListManager:new (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    dofile(SKIN:GetVariable('@')..'Scripts\\StreamsBase.lua')

    self.__measureCount = SKIN:GetVariable('measureCount', self.__maxCount)
    self.__width = SKIN:GetVariable('width', 300)

    for index=0,self.__maxCount do
        local groupName = StreamGroup(index)

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
    return o
end

function ListManager:Print(reloadImages)
    self:HideAll()

    local startIndex = (self.__pageNumber * self.__measureCount)
    local endIndex = startIndex + self.__measureCount - 1
    endIndex = math.min(#self.List - 1, endIndex)

    self.__skinHeight=30
    local measureIndex=0
    for i = startIndex,endIndex do
        local listItem = self.List[i + 1]
        self:PrintTile(measureIndex, listItem, reloadImages)
        measureIndex=measureIndex+1
    end

    self:PrintNavigation()
    __timestamp = os.date("%I:%M %p")
    --self:PrintLastUpdated()
end

function ListManager:HideAll()
    for index=0, self.__measureCount do
        groupName='StreamGroup'..index
        SKIN:Bang('!HideMeterGroup',groupName)
    end
end

function ListManager:PrintTile(index, listItem, reloadImage)
    local title = listItem["title"] or ""
    local line1 = listItem["line1"] or ""
    local line2 = listItem["line2"] or ""
    local details = listItem["details"] or ""
    local imageURL = listItem["imageURL"] or "" 
    local link = listItem["link"] or ""
    local statusColor = listItem["statusColor"] or ""

    local expanded = (self.__expandedIndex == index)

    local width = self.__width
    local sidebarWidth = 30
    if details == "" then
        sidebarWidth = 0
    end
    local height = 120
    if not expanded then
        height = 60
    end

    local startX = "60"
    local startY = self.__skinHeight
    self.__skinHeight = self.__skinHeight + height
  
    -- Show Group
    SKIN:Bang('!ShowMeterGroup',StreamGroup(index))
  
	-- Background
    SetPosition(MeterBackground(index),0,startY-3)
    SetSize(MeterBackground(index),width - sidebarWidth,height-2)
    SetLeftMouseUpAction(MeterBackground(index), link)

	-- Title
    SetTitle(MeterStreamTitle(index),title)
    SetPosition(MeterStreamTitle(index),startX,startY)
    SetFontColor(MeterStreamTitle(index), statusColor)

	-- Line 1
    SetTitle(MeterStreamGame(index),line1)
    SetPosition(MeterStreamGame(index),startX,startY+18)
    SetFontColor(MeterStreamGame(index), statusColor)
	
	-- Line 2
    SetTitle(MeterStreamViewers(index),line2)
    SetPosition(MeterStreamViewers(index),startX,startY+(18*2))
    SetFontColor(MeterStreamViewers(index), statusColor)
	
	-- Image
    if reloadImage then
        SetMeasureURL(MeasureStreamImage(index),imageURL)
    end
    SetPosition(MeterStreamImage(index),5,startY)
    SKIN:Bang('!SetOption',MeterStreamImage(index),'W',50)
    --SetSize(MeterStreamImage(index),40,40)
  
    -- Chevrons
    Hide(MeterStreamChevronUp(index))
    Hide(MeterStreamChevronDown(index))

    -- Details
    if details ~= "" then

        -- Sidebar
        SetPosition(MeterStreamSidebar(index),width - sidebarWidth,startY-3)
        SetSize(MeterStreamSidebar(index),sidebarWidth,height)

         -- Chevrons
        if not expanded then
            Show(MeterStreamChevronDown(index))
            SetPosition(MeterStreamChevronDown(index),width-20,startY+40)
            SetSize(MeterStreamChevronDown(index),12,10)
        else 
            Show(MeterStreamChevronUp(index))
            SetPosition(MeterStreamChevronUp(index),width-20,startY+40)
            SetSize(MeterStreamChevronUp(index),12,10)
        end
    
        -- Details
        if expanded then
            SetTitle(MeterStreamDetails(index), details)
            SetPosition(MeterStreamDetails(index), 5, startY + 60)
            SetSize(MeterStreamDetails(index),width - sidebarWidth,60)
        else 
            SetTitle(MeterStreamDetails(index),"")
            SetSize(MeterStreamDetails(index),0,0)
        end
    end

    -- Divider
    SetPosition(MeterStreamDivider(index),0,startY + height-4)
    SetSize(MeterStreamDivider(index), width, 1)
end

-- Navigation

function ListManager:PrintNavigation()
    SetSize('MeterNavPrevious', 12, 12)
    SetSize('MeterNavNext', 12, 12)
    SetPosition('MeterNavPrevious',16,6)
    SetPosition('MeterNavNext',32,6)

    Hide('MeterNavPrevious')
    Hide('MeterNavNext')
    if self.__pageNumber > 0 then
        Show('MeterNavPrevious')
    end

    local maxPageCount = math.ceil(#self.List / self.__measureCount)
    if self.__pageNumber < (maxPageCount - 1) then
        Show('MeterNavNext')
    end
end

function ListManager:ExpandRow(index)
    if self.__expandedIndex == index then
        self.__expandedIndex = -1
    else 
        self.__expandedIndex = index
    end   

    self:Print(false)
end

function ListManager:NextPage()
    self.__pageNumber = self.__pageNumber + 1
    self:Print(true)
end

function ListManager:PreviousPage()
    self.__pageNumber = math.max(self.__pageNumber - 1, 0)
    self:Print(true)
end

function ListManager:PrintLastUpdated()
    SetTitle('MeterLastUpdated','Last Updated at '..__timestamp)
    SetPosition('MeterLastUpdated',WIDTH,__skinHeight)
end

function ListManager:Refresh()
    self:HideAll()
    SKIN:Bang("!CommandMeasure", "MeasureTwitchParser", "Update");
end