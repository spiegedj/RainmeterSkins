function InitializeGraph(positionX, positionY, width, height, title)
    LOOKBACK_DAYS = 6

    __meterCount = 8
    __positionX = positionX
    __positionY = positionY
    __width = width
    __height = height

    __paddingX = 40
    __padding = 15

    __xValues = {}
    __xSpacing = (__width - (__paddingX + __padding)) / LOOKBACK_DAYS
    __maxY = 0
    __minY = 0
    __rangeY = 0

    __BuildXValues()
    __DrawAxis()

    SetSize("MeterBackground", __width, __height)
    SetPosition("MeterBackground", __positionX, __positionY)
end

function Graph(data)
    __Clear()
    __BuildXValues()
    local header1 = data[1][1]
    local header2 = data[1][2]

    SetPosition("MeterGraphTitle", __width/2, __positionY - 20)
    SetTitle("MeterGraphTitle", header2)
    __GetMaxMins(data)
    __DrawYLabels()

    -- Remove the row/col headers
    table.remove(data, 1)

    __path = ''
    local prevY = ''
    for i=1,#__xValues do
        local x = i - 1
        local y = __FindYValue(data, __xValues[i])

        if y == '' or y == nil then
            y = prevY
        end

        if y ~= nil and y ~= '' then
            xPix, yPix = __ConvertCoordinateToPixels(x, __ParseNumber(y))
            __AddPointToPath(xPix, yPix)
            __DrawPoint(x, xPix, yPix, y)
            prevY = y
        end
    end

    __DrawPath('MeterGraphData', __path)
end

function __ConvertCoordinateToPixels(x, y)
    local xPix = (x * __xSpacing) + __paddingX
    local yPix = ((y - __minY) / __rangeY) * (__height - __padding)
    yPix = round((__positionY + __height - __padding) - yPix, 0)

    return xPix, yPix
end

function __FindYValue(data, x)
    for i=1,#data do
        local dateString = data[i][1]
        if __ParseDate(dateString) == x then
            return data[i][2]
        end
    end

    return ''
end

function __Clear()
    local i = 0
    for i=0,__meterCount do
        SetTitle('MeterLabelY'..i, "")
        SetTitle('MeterLabelX'..i, "")
        SKIN:Bang('!SetOption','MeterLineY'..i,'Shape','')
    end
end

function __DrawYLabels()
    local i = 0
    for y=__minY,__maxY,__intervalY do
        local xPix, yPix = __ConvertCoordinateToPixels(0, y)

        SetPosition('MeterLabelY'..i, 0, yPix - 10)
        SetTitle('MeterLabelY'..i, y)
        __DrawLine('MeterLineY'..i, __paddingX, yPix, __paddingX + __width, yPix, 'StrokeDashes 10,1.5 | StrokeWidth .5')
        i = i + 1
    end
end

function __BuildXValues()
    local currentDateMs = os.time()

    for i=0,LOOKBACK_DAYS do
        local x = os.date("%m/%d", currentDateMs)
        table.insert(__xValues, 1, x)
        local xPix = __ConvertCoordinateToPixels(i, 0)

        __DrawXLabel(x, LOOKBACK_DAYS - i)
        __DrawLine('MeterLineX'..i, xPix, __positionY, xPix, __positionY + __height - __padding, 'StrokeDashes 10,1.5 | StrokeWidth .5')

        -- Subtract a day
        currentDateMs = currentDateMs - (60 * 60 * 24)
    end
end

function __DrawXLabel(label, i)
    SetPosition('MeterLabelX'..i, (i * __xSpacing) + __paddingX, __positionY + __height - __padding + 8)
    SetTitle('MeterLabelX'..i, label)
end

function __GetMaxMins(data)
    __maxY = __ParseNumber(data[2][2])
    __minY = __ParseNumber(data[2][2])

    for i=(#data - 20),#data do
        local y = __ParseNumber(data[i][2])

        if y > __maxY then
            __maxY = y
        end
        
        if y < __minY then
            __minY = y
        end
    end

    __intervalY = math.pow(10, math.floor(math.log10(__maxY - __minY)))
    if ((__maxY - __minY) / __intervalY) > 5 then
        __intervalY = __intervalY * 2
    end

    __minY = math.floor(__minY / __intervalY) * __intervalY
    __maxY = math.ceil(__maxY / __intervalY) * __intervalY
    __rangeY = __maxY - __minY
end

function __DrawAxis()
    local xx1 = __paddingX
    local xx2 = __width
    local xy = (__positionY + __height) - __padding

    local yx = __paddingX
    local yy1 = __positionY
    local yy2 = __positionY + __height - __padding

    __DrawLine('MeterAxisX', xx1, xy, xx2, xy, 'StrokeWidth 2')
    __DrawLine('MeterAxisY', yx, yy1, yx, yy2, 'StrokeWidth 2')
end

function __DrawLine(meter,x1,y1,x2,y2,options)
    SKIN:Bang('!SetOption',meter,'Shape','Line '..x1..','..y1..','..x2..','..y2..' | StrokeColor 255,255,255 | '..options)
end

function __DrawPoint(i, xPix, yPix, y)
    SetTooltipText('MeterPointTrigger'..i, y)
    SetPosition('MeterPoint'..i, xPix, yPix)
    SetPosition('MeterPointTrigger'..i,xPix-5,yPix-5)
end

function __AddPointToPath(pX, pY)
    if __path ~= '' then
        __path=__path..' | LineTo '
    end

    __path=__path..pX..','..pY
end

function __DrawPath(meter, path)
    SKIN:Bang('!SetOption',meter,'Shape','Path MyPath | StrokeWidth 3 | Stroke Color 255,138,0,255')
    SKIN:Bang('!SetOption',meter,'MyPath', path)
end

function __ParseDate(dateString)
    local month,day,year = dateString:match("(%d+)/(%d+)/(%d+)")
    if tonumber(day) < 10 then
        day = '0'..day
    end
    if tonumber(month) < 10 then
        month = '0'..month
    end
    return month..'/'..day
end

function __ParseNumber(numberString)
    numberString = string.gsub(numberString, ",", "")
    numberString = string.gsub(numberString, "%%", "")
    return tonumber(numberString)
end