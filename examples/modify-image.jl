# this recipe demonstrates how to modify an image of a HDU of a FITS file.
# It modifies an existing file.
# Limitation: you cannot modify the image size. For that case, see
# recipe `copy-and-modify-file.jl`.

using AstroFITS

# we create an example file for the test
fits_filepath = mktemp()[1]
data = fill(0, (4, 4, 100))
writefits!(fits_filepath, (), data)


# we must open the file in read-write mode:
f = openfits(fits_filepath, "rw")
# if you open in read mode, it may seem to work, but you will get an
# error when the actual writing takes place (when closing the file for example).


hdu = f[1]


# read some sub area
A = read(hdu, 2:3, 4:4, 54:57)

# do some modification
A .+= 1000

# write the modified area back:
# we have to define first and last coordinates of the area
write(hdu, A; first=(2,4,54), last=(3,4,57))


close(f) # triggers actual writing


