"""
    AstroFITS.CFITSIO_VERSION

Version number of the CFITSIO library for which `AstroFITS` has been built. When `AstroFITS`
is loaded, it is checked that the version of the CFITSIO library does match this version.

"""
const CFITSIO_VERSION = VersionNumber(CFITSIO.CFITSIO_MAJOR,
                                      CFITSIO.CFITSIO_MINOR,
                                      CFITSIO.CFITSIO_MICRO)

if !isdefined(Base, :get_extension)
    using Requires
end

function __init__()
    @static if !isdefined(Base, :get_extension)
        # Extend DataFrames when this package is loaded.
        @require DataFrames="a93c6f00-e57d-5684-b7b6-d8193f3e46c0" begin
            include("../ext/AstroFITSDataFramesExt.jl")
        end
    end
end
