# ps12image operator

#### Description

`ps12image` operator extracts tags from tiff images. 

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
`PS12`            | character, PS12
`Row`             | numeric, row number
`Temperature`     | numeric, temperature
`Timestamp`       | character, timestamp
`Instrument Unit` | character, Instrument Unit
`Protocol ID`     | character, protocol ID

##### Details
This operator is able to perform the retrieval of tags included in tiff images. The tiff images are included in the zip file referenced by the documentID, inside the directory "ImageResults". The operator is using an adjusted version of the ijtiff package to be able to read the needed image tags.

##### See Also

[ijtiff package](https://github.com/tercen/ijtiff)
