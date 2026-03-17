# This file demonstrates basic techniques for writing a FITS file.

using AstroFITS

# we create an example file for the test
fits_filepath = mktemp()[1]


# ========================= #
# ===     open file     === #
# ========================= #

# open file in write mode
f = openfits(fits_filepath, "w")
# error if file already exists

# in case the file already exists, to overwrite it
f = openfits(fits_filepath, "w!")

# close file (triggers actual writing)
close(f)

# open and close for a "do block"
FitsFile(fits_filepath, "w!") do f
    # do something with `f`
    write(f, (), [0 0; 1 1])

    # the file will be closed after this block, so you must
    # NOT finish the block with a value depending on the file
    # to be open, for example `f` or `f[1]`
    nothing
end


# ========================== #
# ===     HDU (image)    === #
# ========================== #

H = FitsHeader()
data_size = (2, 2)
D = [0 0; 1 1]


# write one HDU image to a fits filepath
writefits(fits_filepath, H, D)
# error if file already exists

# same but overwrite destination file
writefits!(fits_filepath, H, D)


# write one HDU image to a opened file
f = openfits(fits_filepath, "w!")
write(f, H, D)


# declare a new image HDU in an opened file
hdu = FitsImageHDU{Float64}(f, data_size)
# you can change eltype `Float64`, example `Int32`

# write a header keyword to a declared HDU
hdu["EXPTIME"] = (12.3, "[s] exposure time")
# must be done before writing data

# write image data to a declared HDU (it writes to the file of the HDU)
write(hdu, D)

# ========================== #
# ===     HDU (table)    === #
# ========================== #

H = FitsHeader()

# three columns for this example
D = [
    "NAME"    => ["monday", "tuesday", "wednesday"],
    "NUMBER"  => ([1,2,3], "ordinal"),  # can specify the units (here ordinal)
    "SIGNALS" => [ true    true   false ;
                   false   true   true  ; # can be dimensional,
                   false   true   false ; # last dimension must be for the table's rows
                   true    true   false ;
                   false   false  true  ]
]

# write one HDU table to a fits filepath
writefits(fits_filepath, H, D)
# error if file already exists

# same but overwrite destination file
writefits!(fits_filepath, H, D)


# write one HDU table to a opened file
write(f, H, D)


# declare a new table HDU in an opened file
tablehdu = FitsTableHDU(f, [
    "NAME"    => (String, 9), # for strings we must specify number of characters
    "NUMBER"  => (Int, "ordinal"), # we specify the unit here
    "SIGNALS" => (Bool, 5) # must indicate the dimensions size (not the rows)
])

# you can add header keywords like for image HDU, see above

# write one data column
write(tablehdu, "NAME" => ["monday", "tuesday", "wednesday"])

# write several data columns
write(tablehdu, "NAME" => ["monday", "tuesday", "wednesday"],
                "NUMBER" => [1,2,3])
