function Initialize()
    -- Imports
    dofile(SKIN:GetVariable('@')..'Scripts\\XMLParser.lua')
    dofile(SKIN:GetVariable('@')..'Scripts\\Utils.lua')
    dofile(SKIN:GetVariable('@')..'Scripts\\ListManager.lua')

    -- Globals
    __Mail = {}
    __ListManager = ListManager:new(nil)
end

function GetMail()
    local measure = SKIN:GetMeasure('MeasureGetMail')
    local raw = measure:GetStringValue()
    print(raw)
    local response = XMLParse(raw)
    
    __Mail = {}
    local hash = {}
    for i, event in pairs(response["events"]) do
        --__Events[i] = ConstructEvent(event, hash)
    end


    __ListManager.List = __Mail
    __ListManager:Print(true)
end


-- Navigation

function NextPage()
    __ListManager:NextPage()
end

function PreviousPage()
    __ListManager:PreviousPage()
end