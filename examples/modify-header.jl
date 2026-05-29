# This recipe demonstrates how to modify a header of a HDU of a FITS file.
# It modifies an existing file.

using AstroFITS

# we create an example file for the test
fits_filepath = mktemp()[1]
header = FitsHeader("NAME"  => ("Henry", "client first name"),
                    "MONEY" => (100.0, "[euros] client balance"))
data = [0 0; 1 1]
writefits!(fits_filepath, header, data)


# we must open the file in read-write mode:
f = openfits(fits_filepath, "rw")
# if you open in read mode, it may seem to work, but you will get an
# error when the actual writing takes place (when closing the file for example).


hdu = f[1]


# add a new header keyword
hdu["FAM-NAME"] = ("MacFits", "client family name")

# modify an existing header keyword
hdu["NAME"] = ("John", "client first name")

# modify an existing header keyword, but keeping comment and changing value and units
money = hdu["MONEY"]
hdu["MONEY"] = (money.float * 1.2, "[dollars] $(money.unitless)")

# note that each add/modify generates a write command to the file.
# so if you have a lot to do, consider using the
# recipe `copy-and-modify-file.jl` instead,
# and work on the `FitsHeader` structure.


close(f) # triggers actual writing


