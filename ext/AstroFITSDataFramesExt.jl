module AstroFITSDataFramesExt

if isdefined(Base, :get_extension)
    using AstroFITS
    using DataFrames
else
    using ..AstroFITS
    using ..DataFrames
end

"""
    nrow(hdu::FitsTableHDU)

Return the number of rows of the FITS Table extension in `hdu`.

"""
DataFrames.nrow(hdu::FitsTableHDU) = hdu.nrows

"""
    ncol(hdu::FitsTableHDU)

Return the number of columns of the FITS Table extension in `hdu`.

"""
DataFrames.ncol(hdu::FitsTableHDU) = hdu.ncols

end # module
