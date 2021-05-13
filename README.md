# ps12image operator

#### Description

`ps12image` operator performs data retrieval and analysis of tiff images.

##### Usage

Input projection|.
---|---
`row`        | is the documentId 

Output relations|.
---|---
`documentId`      | character, documentId of the zip file
`path`            | character, path of the images
`Image`           | character, image filename
`DateTime`        | character, date and time the image was created
`Barcode`         | character, barcode of the image
`Col`             | numeric, col of the image
`Cycle`           | numeric, cycle of the image
`Exposure Time`   | numeric, exposure time of the image
`Filter`          | character, filter
`PS12`            | character, slope of the linear regression model
`Row`             | numeric, row number
`Temperature`     | numeric, temperature
`Timestamp`       | character, slope of the linear regression model
`Instrument Unit` | character, Instrument Unit
`Protocol ID`     | character, protocol ID

##### Details
This operator is able to perform the retrieval of tags included in tiff images. The tags that are needed are:

DateTime,	Barcode,	Col,	Cycle,	Exposure, Time,	Filter,	PS12,	Row, Temperature, Instrument unit, Protocol ID


#### Reference


##### See Also

[ps12image operator](https://github.com/tercen/ps12image_operator)

#### Examples