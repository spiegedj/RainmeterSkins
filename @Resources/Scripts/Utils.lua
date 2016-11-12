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

function HideGroup(group)
	SKIN:Bang('!HideMeterGroup',group)
end

function ShowGroup(group)
	SKIN:Bang('!ShowMeterGroup',group)
end