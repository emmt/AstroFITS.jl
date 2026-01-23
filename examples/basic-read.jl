# This file demonstrates basic techniques for reading a FITS file.

using AstroFITS

# we create an example file for the test
fits_filepath = mktemp()[1]
writefits!(fits_filepath,
    FitsHeader("HDUNAME" => "IMG", "EXPTIME" => (12.3, "[s] exposure time")),
    [0 0; 1 1],
    FitsHeader("EXTNAME" => "TAB"),
    [ "NUMBER" => ([1,2,3], "ordinal"),
      "NAME"   => ["monday", "tuesday", "wednesday"] ])


# ========================= #
# ===     open file     === #
# ========================= #

# open file for reading
f = openfits(fits_filepath)

# close file
close(f)

# open and close for a "do block"
FitsFile(fits_filepath) do f
    # do something with `f`
    f[1]["NAXIS"].integer

    # The file will be closed after this block, so if you end this block with
    # a value depending on the file to be open, for example `f` or `f[1]`,
    # you will get an error.
end

# open again for the rest of the tutorial
f = openfits(fits_filepath)


# =================== #
# ===     HDU     === #
# =================== #

# get number of HDUs
length(f)

# select primary HDU
hdu = f[1]
# This does not read the header keywords, nor the data.
# This structure is not available after file closure.

# select HDU by "HDUNAME" header keyword
img_hdu = f["IMG"]

# select HDU by "EXTNAME" header keyword
tab_hdu = f["TAB"]


# =============================== #
# ===     Header Keywords     === #
# =============================== #

# read one header keyword card from one HDU
img_hdu["EXPTIME"]
#> FitsCard: EXPTIME = 12.3 / [s] exposure time
# a keyword card is a structure, see package `FITSHeaders` for more documentation

# read one header keyword card from one HDU, and get its value
hdu["EXPTIME"].float
#> 12.3
hdu["HDUNAME"].string
#> "IMG"
hdu["NAXIS"].integer
#> 2
hdu["SIMPLE"].logical
#> true
hdu["EXPTIME"].value() # any type found
#> 12.3

# read every header keyword from one HDU
H = FitsHeader(hdu)
# this structure remains available after file closure
# see package `FITSHeaders` for more documentation

# same but from filepath
H = readfits(FitsHeader, fits_filepath)
H = readfits(FitsHeader, fits_filepath; ext=1)
H = readfits(FitsHeader, fits_filepath; ext="IMG")

# get number of header keywords
length(H)

# get one keyword card from one FitsHeader
H["EXPTIME"]

# get one keyword card from one FitsHeader, and get its value
H["EXPTIME"].float

# iterate through keyword cards from one FitsHeader
for card in H
    println(card.name, " = ", card.value())
end


# ============================ #
# ===     Data (image)     === #
# ============================ #

# read data from one HDU
D = read(img_hdu)
# this structure remains available after file closure (it is a standard julia array)

# read partially from one HDU
D = read(img_hdu, 1:2, 1)
#> Vector

# read from one HDU and cast element type
D = read(Array{Float32}, img_hdu)

# same but from file path
D = readfits(fits_filepath)
D = readfits(fits_filepath; ext="IMG")
D = readfits(fits_filepath, 1:2, 1)
D = readfits(Array{Float32}, fits_filepath)

# read data size
img_hdu.data_size
#> (2, 2)

# read element type
img_hdu.data_eltype
#> Int64


# ============================ #
# ===     Data (table)     === #
# ============================ #

# read columns names from one HDU
tab_hdu.column_names
#> ["NUMBER", "NAME"]

# read number of rows
tab_hdu.nrows
#> 3

# read every column
D = read(tab_hdu)
#> Dict("NUMBER" => [1,2,3], "NAME" => ["monday","tuesday","wednesday"])
# this structure remains available after file closure (it is a standard julia dict)

# read one column
C = read(tab_hdu, "NUMBER")
#> [1,2,3]
# last dimension of the returned array is for the rows of the table HDU
# this structure remains available after file closure

# same with column number
C = read(tab_hdu, 1)
#> [1,2,3]

# read several columns
D = read(tab_hdu, ["NUMBER", "NAME"])
#> Dict("NUMBER" => [1,2,3], "NAME" => ["monday","tuesday","wednesday"])

# read some lines of one column
C = read(tab_hdu, "NAME", 2:3)
#> ["tuesday","wednesday"]

# read some lines of several columns
D = read(tab_hdu, ["NUMBER","NAME"], 2:3)
#> Dict("NUMBER" => [2,3], "NAME" => ["tuesday","wednesday"])

# read one column and cast element type
C = read(Array{Float32}, tab_hdu, "NUMBER")
#> [1.0, 2.0, 3.0]


close(f)
