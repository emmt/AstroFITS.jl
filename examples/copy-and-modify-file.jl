# This recipe demonstrates how to copy each HDU of a file to another filepath, allowing you
# to modify some HDUs on the way, or to add or delete some HDUs.

using AstroFITS

# we create an example file for the test
fits_filepath = mktemp()[1]
writefits!(fits_filepath,
    FitsHeader("HDUNAME" => "IMG"), [0 0; 1 1],
    FitsHeader("EXTNAME" => "TAB"), [ "NUMBER" => ([1,2,3], "ordinal"),
                                      "NAME"   => ["monday", "tuesday", "wednesday"] ],
    FitsHeader("HDUNAME" => "PSSWD"), [0,1,0,0,0,1,1,0])


# you cannot use the same filepath in input and output
output_filepath = mktemp()[1]


f_in = openfits(fits_filepath)
f_out = openfits(output_filepath, "w!")


# copy the whole file without modification
append!(f_out, f_in)


# copy some hdus
append!(f_out, f_in[1:2])
append!(f_out, f_in["PSSWD"])
# you can use this to insert some hdus,
# or to avoid copying some hdus


# modify image hdu "IMG", table hdu "TAB", and copy the others
for hdu in f_in

    if hdu.hduname == "IMG"
        # it is best to work on structures that are disconnected from the input file,
        # such as FitsHeader and julia array
        H = FitsHeader(hdu)
        D = read(hdu)
        
        push!(H, "TARGET" => "a cat")
        
        D2 = Array{eltype(D)}(undef, 2, 2, 2)
        D2[:,:,1] .= D
        D2[:,:,2] .= [2 2; 3 3]
        
        # need to filter out structural keywords, as they are infered from data
        H2 = filter(!is_structural, H)
        
        write(f_out, H2, D2)

    elseif hdu.extname == "TAB"
        H = FitsHeader(hdu)
        D = read(hdu)
        
        # adding a column
        D["TEMPERATURE"] = [10.1, 12, 19.4]
        
        # adding a row
        push!(D["NUMBER"], 4)
        push!(D["NAME"], "thursday")
        push!(D["TEMPERATURE"], 18.5)
        
        # need to filter out structural keywords, as they are infered from data
        # need to filter our TUNIT keywords as they are column order dependent,
        # and we may change that order
        H2 = filter(c -> !startswith(c.name, "TUNIT"), filter(!is_structural, H))
        
        write(f_out, H2, [
            # we can change order of columns
            "COLOR"  => (D["TEMPERATURE"], "deg celsius"),
            "NAME"   =>  D["NAME"],
            "NUMBER"   => (D["NUMBER"], hdu.column_units("NUMBER")) # copy TUNIT
        ])
        
    else # copy HDU
        append!(f_out, hdu)
    end
end

close(f_in)
close(f_out)

