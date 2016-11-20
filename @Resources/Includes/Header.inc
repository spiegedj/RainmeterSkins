[MeterTitleBackground]
Meter=Image
W=#width#
H=25
SolidColor=#headerColor#

[MeterTitle]
Meter=String
MeterStyle=styleTitle
Text=#SkinName#
X=(#width#/2)

[MeterRefresh]
Meter=Image
ImageName="#@#images/refresh.png"
W=16
H=16
X=(#width#-23)
Y=5s
LeftMouseUpAction=[!CommandMeasure MainScript Refresh()][!Update]