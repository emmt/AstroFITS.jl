# This recipe demonstrates how to write an image data bunch by bunch,
# instead of writing the whole image in one command.
# The goal is to avoid storing a huge complete image in RAM.

using AstroFITS

# we create an example file for the test
fits_filepath = mktemp()[1]

f = openfits(fits_filepath, "w!")

data_eltype = Float64
data_size = (4, 4, 100)

# we use HDU declaration, to declare the size
hdu = FitsImageHDU{data_eltype}(f, data_size)

# first bunch of data (random values for the example)
first_D = rand(4, 4)
i = 1 # linear index to start writing from. 1 is the first cell
write(hdu, first_D; first=i)
i += length(first_D) # we move the index beyond the first bunch

# second bunch of data
second_D = rand(4, 4, 3) # no need to have same size for every bunch
write(hdu, second_D; first=i)
i += length(second_D)

# etc

close(f) # triggers actual writing

# With this technique you can even write to different HDUs alternatively.


