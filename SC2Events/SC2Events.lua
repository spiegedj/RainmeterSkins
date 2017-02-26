function Initialize()
    -- Imports
    dofile(SKIN:GetVariable('@')..'Scripts\\JSONParser.lua')
    dofile(SKIN:GetVariable('@')..'Scripts\\Utils.lua')
    dofile(SKIN:GetVariable('@')..'Scripts\\ListManager.lua')

    -- Globals
    __Events = {}
    __ListManager = ListManager:new(nil)
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

    __ListManager.List = __Events
    __ListManager:Print(true)
end

function Refresh()
    if #__Events == 0 then return end

    for i, event in pairs(__Events) do
        event["game"] = GetCountdownString(event["timeMS"])
    end

    __ListManager:Print(false)
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

    eventSummary["title"]=cleanString(name)..": "..cleanString(details)
    eventSummary["line1"]=cleanString(countdown)
    eventSummary["line2"]=cleanString(date)
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
        local compareValueA = a["timeMS"]
        local compareValueB = b["timeMS"]
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