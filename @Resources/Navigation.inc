[MeterNavPrevious]
Meter=Image
ImageName=#@#Images\TriangleLeft.png
ImageAlpha=200
MouseOverAction=[!SetOption MeterNavPrevious SolidColor #colorOptionShow#][!Update]
MouseLeaveAction=[!SetOption MeterNavPrevious SolidColor #transparent#][!Update]
LeftMouseUpAction=[!CommandMeasure MainScript PreviousPage()][!Update]
Hidden=1

[MeterNavNext]
Meter=Image
ImageName=#@#Images\TriangleRight.png
ImageAlpha=200
MouseOverAction=[!SetOption MeterNavNext SolidColor #colorOptionShow#][!Update]
MouseLeaveAction=[!SetOption MeterNavNext SolidColor #transparent#][!Update]
LeftMouseUpAction=[!CommandMeasure MainScript NextPage()][!Update]
Hidden=1