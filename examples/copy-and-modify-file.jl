# this recipe demonstrates how to copy each HDU of a file to another filepath, allowing you
# to modify some HDUs on the way, or to add or delete some HDUs.

using AstroFITS

# we create an example file for the test
fits_filepath = mktemp()[1]
writefits!(fits_filepath,
    FitsHeader("HDUNAME" => "IMG"), [0 0; 1 1],
    FitsHeader("HDUNAME" => "TAB"), [ "NUMBER" => [1,2,3],
                                      "NAME"   => ["monday", "tuesday", "wednesday"] ])


# you cannot use the same filepath in input and output
output_filepath = mktemp()[1]


f_in = openfits(fits_filepath)
f_out = openfits(output_filepath, "w!")

# let's say f_in contains HDUs "A", "B", and "C"
for hdu in f_in
    # replace `hduname == "B"` with your own test
    if hdu.hduname == "B"
        # here you can do what you want with hdu "B"
        H = FitsHeader(hdu)
        D = read(hdu)
        
        # you can augment the header
        push!(H, "TOTO" => 44)
        
        # in case of an image you can reshape it for example
        D = reshape(D, 16, 4)
        # if so you MUST modify the structural keywords (NAXIS, etc) accordingly in `H`
        H["NAXIS"] = 2
        H["NAXIS1"] = 16
        H["NAXIS2"] = 4
        
        write(f_out, H, D)
    else # copy HDU
        H = FitsHeader(hdu)
        # remove structural keywords to avoid problems
        H = filter(!FITSHeaders.Parser.is_structural, H)
        D = read(hdu)
        write(f_out, H, D)
    end
end

close(f_in)
close(f_out)

