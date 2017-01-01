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

function SetTooltipText(meter,text)
	SKIN:Bang('!SetOption',meter,'ToolTipText',text)
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

function HideGroup(group)
	SKIN:Bang('!HideMeterGroup',group)
end

function ShowGroup(group)
	SKIN:Bang('!ShowMeterGroup',group)
end

function SetFormula(measure, value)
	SKIN:Bang("!SetOption", measure, "formula", value);
end

function SetImageName(measure, name)
	SKIN:Bang("!SetOption", measure, "ImageName", name);
end

function SetFontColor(measure, color)
	SKIN:Bang('!SetOption', measure, 'FontColor', color)
end

function cleanString(s)
	return trim(s or "")
end

function trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end