# This recipe demonstrates how to copy each HDU of a file to another filepath, allowing you
# to modify some HDUs on the way, or to add or delete some HDUs.

using AstroFITS

# we create an example file for the test
fits_filepath = mktemp()[1]
writefits!(fits_filepath,
    FitsHeader("HDUNAME" => "IMG"), [0 0; 1 1],
    FitsHeader("HDUNAME" => "TAB"), [ "NUMBER" => ([1,2,3], "ordinal"),
                                      "NAME"   => ["monday", "tuesday", "wednesday"] ])


# you cannot use the same filepath in input and output
output_filepath = mktemp()[1]


f_in = openfits(fits_filepath)
f_out = openfits(output_filepath, "w!")

# we will modify hdu "IMG" and copy the others
for hdu in f_in

    if hdu.hduname == "IMG"
        H = FitsHeader(hdu)
        D = read(hdu)
        
        push!(H, "TARGET" => "a cat")
        
        D2 = Array{eltype(D)}(undef, 2, 2, 2)
        D2[:,:,1] .= D
        D2[:,:,2] .= [2 2; 3 3]
        
        # need to filter out structural keywords, as they are infered from data
        write(f_out, filter(!is_structural, H), D2)

    else # copy HDU
        H = FitsHeader(hdu)
        D = read(hdu)
        # need to filter out structural keywords, as they are infered from data
        write(f_out, filter(!is_structural, H), D)
    end
end

close(f_in)
close(f_out)

